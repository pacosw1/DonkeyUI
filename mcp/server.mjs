#!/usr/bin/env node
//
// DonkeyUI MCP Server
// Exposes the component library to Claude via MCP tools.
//
// Tools:
//   search_components  — FTS search across all components, models, extensions, helpers
//   get_component      — Get full details for a specific component by name
//   list_categories    — List all available categories
//   list_components    — List all components in a category
//   get_theme_setup    — Get theme configuration instructions
//   get_usage_example  — Get usage example for a specific component
//

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from '@modelcontextprotocol/sdk/node_modules/zod/lib/index.mjs';
import Database from 'better-sqlite3';
import { join, dirname } from 'path';
import { fileURLToPath, URL } from 'url';
import { readFileSync, existsSync } from 'fs';
import { execSync } from 'child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DB_PATH = join(__dirname, 'components.db');

// Auto-index if DB doesn't exist
if (!existsSync(DB_PATH)) {
	console.error('Database not found, running indexer...');
	execSync('node indexer.mjs', { cwd: __dirname, stdio: 'inherit' });
}

const db = new Database(DB_PATH, { readonly: true });

// ── MCP Server ──────────────────────────────────────────────────────────────

const server = new Server(
	{ name: 'donkeyui', version: '1.0.0' },
	{ capabilities: { tools: {} } }
);

// ── Tools ───────────────────────────────────────────────────────────────────

server.setRequestHandler({ method: 'tools/list' }, async () => ({
	tools: [
		{
			name: 'search_components',
			description: 'Search DonkeyUI components, models, extensions, helpers, and modifiers by keyword. Use this to find the right component for a task. Returns name, category, type, description, and usage for each match.',
			inputSchema: {
				type: 'object',
				properties: {
					query: { type: 'string', description: 'Search query — component name, feature description, or keyword (e.g. "paywall", "button loading", "date format", "subscription", "sign in", "skeleton")' },
					type: { type: 'string', description: 'Filter by type: component, model, extension, modifier, helper, theme, store, auth, onboarding, event_tracking', enum: ['component', 'model', 'extension', 'modifier', 'helper', 'theme', 'store', 'auth', 'onboarding', 'event_tracking'] },
					limit: { type: 'number', description: 'Max results (default: 10)', default: 10 },
				},
				required: ['query'],
			},
		},
		{
			name: 'get_component',
			description: 'Get full documentation for a specific DonkeyUI component by exact name. Returns init signature, usage example, and full documentation.',
			inputSchema: {
				type: 'object',
				properties: {
					name: { type: 'string', description: 'Exact component name (e.g. "PaywallScreen", "DonkeyStoreManager", "ThemedCard")' },
				},
				required: ['name'],
			},
		},
		{
			name: 'list_categories',
			description: 'List all DonkeyUI categories with component counts. Use this to discover what\'s available.',
			inputSchema: { type: 'object', properties: {} },
		},
		{
			name: 'list_components',
			description: 'List all components in a specific category.',
			inputSchema: {
				type: 'object',
				properties: {
					category: { type: 'string', description: 'Category name (e.g. "Components (Themed)", "Extensions", "Helpers", "Store (StoreKit 2)")' },
				},
				required: ['category'],
			},
		},
		{
			name: 'get_theme_setup',
			description: 'Get DonkeyUI theme configuration instructions and all theme properties.',
			inputSchema: { type: 'object', properties: {} },
		},
		{
			name: 'get_usage_example',
			description: 'Get a quick usage example for a component. Returns just the code snippet.',
			inputSchema: {
				type: 'object',
				properties: {
					name: { type: 'string', description: 'Component name' },
				},
				required: ['name'],
			},
		},
	],
}));

server.setRequestHandler({ method: 'tools/call' }, async (request) => {
	const { name, arguments: args } = request.params;

	switch (name) {
		case 'search_components': {
			const { query, type, limit = 10 } = args;
			let results;

			if (type) {
				results = db.prepare(`
					SELECT c.name, c.category, c.type, c.description, c.usage
					FROM components_fts fts
					JOIN components c ON c.id = fts.rowid
					WHERE components_fts MATCH ? AND c.type = ?
					ORDER BY rank
					LIMIT ?
				`).all(query + '*', type, limit);
			} else {
				results = db.prepare(`
					SELECT c.name, c.category, c.type, c.description, c.usage
					FROM components_fts fts
					JOIN components c ON c.id = fts.rowid
					WHERE components_fts MATCH ?
					ORDER BY rank
					LIMIT ?
				`).all(query + '*', limit);
			}

			// Fallback to LIKE search if FTS returns nothing
			if (results.length === 0) {
				const likeQuery = `%${query}%`;
				if (type) {
					results = db.prepare(`
						SELECT name, category, type, description, usage FROM components
						WHERE type = ? AND (name LIKE ? OR description LIKE ? OR keywords LIKE ? OR body LIKE ?)
						LIMIT ?
					`).all(type, likeQuery, likeQuery, likeQuery, likeQuery, limit);
				} else {
					results = db.prepare(`
						SELECT name, category, type, description, usage FROM components
						WHERE name LIKE ? OR description LIKE ? OR keywords LIKE ? OR body LIKE ?
						LIMIT ?
					`).all(likeQuery, likeQuery, likeQuery, likeQuery, limit);
				}
			}

			if (results.length === 0) {
				return { content: [{ type: 'text', text: `No components found for "${query}". Try a broader search or use list_categories to see what's available.` }] };
			}

			const text = results.map(r =>
				`### ${r.name}\n**Category:** ${r.category} | **Type:** ${r.type}\n${r.description}\n\n\`\`\`swift\n${r.usage}\n\`\`\``
			).join('\n\n---\n\n');

			return { content: [{ type: 'text', text: `Found ${results.length} result(s) for "${query}":\n\n${text}` }] };
		}

		case 'get_component': {
			const { name: componentName } = args;
			const row = db.prepare(`SELECT * FROM components WHERE name = ? COLLATE NOCASE`).get(componentName);

			if (!row) {
				// Try fuzzy match
				const fuzzy = db.prepare(`SELECT name FROM components WHERE name LIKE ? COLLATE NOCASE LIMIT 5`).all(`%${componentName}%`);
				const suggestions = fuzzy.map(r => r.name).join(', ');
				return { content: [{ type: 'text', text: `Component "${componentName}" not found.${suggestions ? ` Did you mean: ${suggestions}?` : ''}` }] };
			}

			const text = [
				`# ${row.name}`,
				`**Category:** ${row.category}`,
				`**Type:** ${row.type}`,
				'',
				row.description,
				'',
				row.init_signature ? `## Init Signature\n\`\`\`swift\n${row.init_signature}\n\`\`\`` : '',
				'',
				row.usage ? `## Usage\n\`\`\`swift\n${row.usage}\n\`\`\`` : '',
				'',
				`## Full Documentation\n${row.body}`,
			].filter(Boolean).join('\n');

			return { content: [{ type: 'text', text }] };
		}

		case 'list_categories': {
			const cats = db.prepare(`
				SELECT category, type, COUNT(*) as count
				FROM components
				GROUP BY category
				ORDER BY category
			`).all();

			const text = cats.map(c => `- **${c.category}** (${c.count} items)`).join('\n');
			return { content: [{ type: 'text', text: `## DonkeyUI Categories\n\n${text}\n\nUse \`list_components\` with a category name to see all items.` }] };
		}

		case 'list_components': {
			const { category } = args;
			const rows = db.prepare(`
				SELECT name, type, description FROM components
				WHERE category LIKE ? COLLATE NOCASE
				ORDER BY name
			`).all(`%${category}%`);

			if (rows.length === 0) {
				return { content: [{ type: 'text', text: `No components found in category "${category}". Use list_categories to see available categories.` }] };
			}

			const text = rows.map(r => `- **${r.name}** (${r.type}) — ${r.description}`).join('\n');
			return { content: [{ type: 'text', text: `## ${category}\n\n${text}` }] };
		}

		case 'get_theme_setup': {
			const themeComponents = db.prepare(`
				SELECT name, body FROM components WHERE category = 'Theme Setup' ORDER BY id
			`).all();

			const text = [
				'# DonkeyUI Theme Setup',
				'',
				'Apply a theme at the root of your view hierarchy:',
				'```swift',
				'ContentView()',
				'    .donkeyTheme(DonkeyTheme(',
				'        colors: DonkeyThemeColors(primary: .blue, accent: .purple),',
				'        shape: DonkeyThemeShape(radiusMedium: 16)',
				'    ))',
				'```',
				'',
				'All components read `@Environment(\\.donkeyTheme) var theme`.',
				'',
				...themeComponents.map(c => `## ${c.name}\n${c.body}`),
			].join('\n');

			return { content: [{ type: 'text', text }] };
		}

		case 'get_usage_example': {
			const { name: componentName } = args;
			const row = db.prepare(`SELECT name, usage, init_signature FROM components WHERE name = ? COLLATE NOCASE`).get(componentName);

			if (!row) {
				return { content: [{ type: 'text', text: `Component "${componentName}" not found.` }] };
			}

			const code = row.usage || row.init_signature || 'No usage example available.';
			return { content: [{ type: 'text', text: `## ${row.name}\n\n\`\`\`swift\n${code}\n\`\`\`` }] };
		}

		default:
			return { content: [{ type: 'text', text: `Unknown tool: ${name}` }] };
	}
});

// ── Start ───────────────────────────────────────────────────────────────────

const transport = new StdioServerTransport();
await server.connect(transport);
