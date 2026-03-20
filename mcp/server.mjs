#!/usr/bin/env node
//
// DonkeyUI MCP Server
// Exposes the component library to Claude via MCP tools.
//

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import Database from 'better-sqlite3';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { existsSync } from 'fs';
import { execSync } from 'child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DB_PATH = join(__dirname, 'components.db');

// Auto-index if DB doesn't exist
if (!existsSync(DB_PATH)) {
	console.error('Database not found, running indexer...');
	execSync('node indexer.mjs', { cwd: __dirname, stdio: 'inherit' });
}

const db = new Database(DB_PATH, { readonly: true });

const server = new McpServer(
	{ name: 'donkeyui', version: '1.0.0' },
	{ capabilities: { tools: {} } }
);

// ── Tools ───────────────────────────────────────────────────────────────────

server.tool(
	'search_components',
	'Search DonkeyUI components, models, extensions, helpers, and modifiers by keyword. Returns name, category, type, description, and usage for each match.',
	{
		query: z.string().describe('Search query — component name, feature, or keyword (e.g. "paywall", "button loading", "date format", "subscription")'),
		type: z.enum(['component', 'model', 'extension', 'modifier', 'helper', 'theme', 'store', 'auth', 'onboarding', 'event_tracking']).optional().describe('Filter by type'),
		limit: z.number().optional().default(10).describe('Max results'),
	},
	async ({ query, type, limit = 10 }) => {
		let results;

		if (type) {
			results = db.prepare(`
				SELECT c.name, c.category, c.type, c.description, c.usage
				FROM components_fts fts JOIN components c ON c.id = fts.rowid
				WHERE components_fts MATCH ? AND c.type = ?
				ORDER BY rank LIMIT ?
			`).all(query + '*', type, limit);
		} else {
			results = db.prepare(`
				SELECT c.name, c.category, c.type, c.description, c.usage
				FROM components_fts fts JOIN components c ON c.id = fts.rowid
				WHERE components_fts MATCH ?
				ORDER BY rank LIMIT ?
			`).all(query + '*', limit);
		}

		// Fallback to LIKE if FTS returns nothing
		if (results.length === 0) {
			const like = `%${query}%`;
			const params = type
				? [type, like, like, like, like, limit]
				: [like, like, like, like, limit];
			const where = type
				? 'type = ? AND (name LIKE ? OR description LIKE ? OR keywords LIKE ? OR body LIKE ?)'
				: 'name LIKE ? OR description LIKE ? OR keywords LIKE ? OR body LIKE ?';
			results = db.prepare(`SELECT name, category, type, description, usage FROM components WHERE ${where} LIMIT ?`).all(...params);
		}

		if (results.length === 0) {
			return { content: [{ type: 'text', text: `No components found for "${query}". Try list_categories to browse.` }] };
		}

		const text = results.map(r =>
			`### ${r.name}\n**Category:** ${r.category} | **Type:** ${r.type}\n${r.description}\n\n\`\`\`swift\n${r.usage}\n\`\`\``
		).join('\n\n---\n\n');

		return { content: [{ type: 'text', text: `Found ${results.length} result(s) for "${query}":\n\n${text}` }] };
	}
);

server.tool(
	'get_component',
	'Get full documentation for a specific DonkeyUI component by exact name. Returns init signature, usage, and full docs.',
	{ name: z.string().describe('Exact component name (e.g. "PaywallScreen", "DonkeyStoreManager")') },
	async ({ name: componentName }) => {
		const row = db.prepare('SELECT * FROM components WHERE name = ? COLLATE NOCASE').get(componentName);

		if (!row) {
			const fuzzy = db.prepare('SELECT name FROM components WHERE name LIKE ? COLLATE NOCASE LIMIT 5').all(`%${componentName}%`);
			const suggestions = fuzzy.map(r => r.name).join(', ');
			return { content: [{ type: 'text', text: `"${componentName}" not found.${suggestions ? ` Did you mean: ${suggestions}?` : ''}` }] };
		}

		const text = [
			`# ${row.name}`,
			`**Category:** ${row.category} | **Type:** ${row.type}`,
			'', row.description, '',
			row.init_signature ? `## Init\n\`\`\`swift\n${row.init_signature}\n\`\`\`` : '',
			row.usage ? `## Usage\n\`\`\`swift\n${row.usage}\n\`\`\`` : '',
			`## Full Docs\n${row.body}`,
		].filter(Boolean).join('\n');

		return { content: [{ type: 'text', text }] };
	}
);

server.tool(
	'list_categories',
	'List all DonkeyUI categories with component counts.',
	{},
	async () => {
		const cats = db.prepare('SELECT category, COUNT(*) as count FROM components GROUP BY category ORDER BY category').all();
		const text = cats.map(c => `- **${c.category}** (${c.count})`).join('\n');
		return { content: [{ type: 'text', text: `## DonkeyUI Categories\n\n${text}` }] };
	}
);

server.tool(
	'list_components',
	'List all components in a specific category.',
	{ category: z.string().describe('Category name (e.g. "Components (Themed)", "Store (StoreKit 2)")') },
	async ({ category }) => {
		const rows = db.prepare('SELECT name, type, description FROM components WHERE category LIKE ? COLLATE NOCASE ORDER BY name').all(`%${category}%`);
		if (rows.length === 0) return { content: [{ type: 'text', text: `No components in "${category}".` }] };
		const text = rows.map(r => `- **${r.name}** (${r.type}) — ${r.description}`).join('\n');
		return { content: [{ type: 'text', text: `## ${category}\n\n${text}` }] };
	}
);

server.tool(
	'get_theme_setup',
	'Get DonkeyUI theme configuration instructions.',
	{},
	async () => {
		const items = db.prepare("SELECT name, body FROM components WHERE category = 'Theme Setup' ORDER BY id").all();
		const text = [
			'# DonkeyUI Theme Setup',
			'```swift',
			'ContentView()',
			'    .donkeyTheme(DonkeyTheme(colors: DonkeyThemeColors(primary: .blue, accent: .purple)))',
			'```',
			'All components read `@Environment(\\.donkeyTheme) var theme`.',
			'',
			...items.map(c => `## ${c.name}\n${c.body}`),
		].join('\n');
		return { content: [{ type: 'text', text }] };
	}
);

server.tool(
	'get_usage_example',
	'Get a quick usage example for a component.',
	{ name: z.string().describe('Component name') },
	async ({ name: componentName }) => {
		const row = db.prepare('SELECT name, usage, init_signature FROM components WHERE name = ? COLLATE NOCASE').get(componentName);
		if (!row) return { content: [{ type: 'text', text: `"${componentName}" not found.` }] };
		return { content: [{ type: 'text', text: `## ${row.name}\n\n\`\`\`swift\n${row.usage || row.init_signature || 'No example available.'}\n\`\`\`` }] };
	}
);

// ── Start ───────────────────────────────────────────────────────────────────

const transport = new StdioServerTransport();
await server.connect(transport);
