#!/usr/bin/env node
//
// Parses COMPONENTS.md into SQLite for fast MCP search.
// Run: node indexer.mjs
//

import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import Database from 'better-sqlite3';

const __dirname = dirname(fileURLToPath(import.meta.url));
const MD_PATH = join(__dirname, '..', 'COMPONENTS.md');
const DB_PATH = join(__dirname, 'components.db');

// ── Parse COMPONENTS.md ─────────────────────────────────────────────────────

function parseComponentsMd(content) {
	const lines = content.split('\n');
	const entries = [];
	let currentCategory = '';
	let currentName = '';
	let currentBody = [];
	let inEntry = false;

	function flush() {
		if (currentName && currentBody.length > 0) {
			const body = currentBody.join('\n').trim();

			// Extract description (first non-empty, non-code line)
			const descLine = currentBody.find(l =>
				l.trim() && !l.startsWith('```') && !l.startsWith('public ') && !l.startsWith('let ') && !l.startsWith('//') && !l.startsWith('|')
			);
			const description = descLine?.trim() || '';

			// Extract code blocks
			const codeBlocks = [];
			let inCode = false;
			let codeLines = [];
			for (const line of currentBody) {
				if (line.startsWith('```swift')) {
					inCode = true;
					codeLines = [];
				} else if (line.startsWith('```') && inCode) {
					inCode = false;
					codeBlocks.push(codeLines.join('\n'));
				} else if (inCode) {
					codeLines.push(line);
				}
			}

			// First code block is usually the init signature, rest are usage examples
			const initSignature = codeBlocks[0] || '';
			const usage = codeBlocks.slice(1).join('\n\n') || codeBlocks[0] || '';

			// Determine type
			let type = 'component';
			const catLower = currentCategory.toLowerCase();
			if (catLower.includes('extension')) type = 'extension';
			else if (catLower.includes('modifier')) type = 'modifier';
			else if (catLower.includes('protocol') || catLower.includes('model')) type = 'model';
			else if (catLower.includes('helper')) type = 'helper';
			else if (catLower.includes('theme')) type = 'theme';
			else if (catLower.includes('store')) type = 'store';
			else if (catLower.includes('auth')) type = 'auth';
			else if (catLower.includes('onboarding')) type = 'onboarding';
			else if (catLower.includes('event')) type = 'event_tracking';
			else if (catLower.includes('button')) type = 'component';
			else if (catLower.includes('icon')) type = 'component';
			else if (catLower.includes('tag')) type = 'component';
			else if (catLower.includes('badge')) type = 'component';
			else if (catLower.includes('progress')) type = 'component';
			else if (catLower.includes('skeleton')) type = 'component';
			else if (catLower.includes('setting')) type = 'component';
			else if (catLower.includes('view')) type = 'component';

			// Build search keywords
			const keywords = [
				currentName.toLowerCase(),
				currentCategory.toLowerCase(),
				type,
				description.toLowerCase(),
			].join(' ');

			entries.push({
				name: currentName,
				category: currentCategory,
				type,
				description,
				initSignature,
				usage,
				body,
				keywords,
			});
		}
		currentBody = [];
	}

	for (const line of lines) {
		if (line.startsWith('## ') && !line.startsWith('### ')) {
			flush();
			currentCategory = line.replace('## ', '').trim();
			currentName = '';
			inEntry = false;
		} else if (line.startsWith('### ')) {
			flush();
			currentName = line.replace('### ', '').trim();
			inEntry = true;
		} else if (inEntry) {
			currentBody.push(line);
		}
	}
	flush();

	return entries;
}

// ── Build SQLite DB ─────────────────────────────────────────────────────────

function buildDatabase(entries) {
	const db = new Database(DB_PATH);

	db.exec(`DROP TABLE IF EXISTS components`);
	db.exec(`
		CREATE TABLE components (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			category TEXT NOT NULL,
			type TEXT NOT NULL,
			description TEXT NOT NULL DEFAULT '',
			init_signature TEXT NOT NULL DEFAULT '',
			usage TEXT NOT NULL DEFAULT '',
			body TEXT NOT NULL DEFAULT '',
			keywords TEXT NOT NULL DEFAULT ''
		)
	`);

	// FTS5 virtual table for full-text search
	db.exec(`DROP TABLE IF EXISTS components_fts`);
	db.exec(`
		CREATE VIRTUAL TABLE components_fts USING fts5(
			name, category, type, description, keywords, body,
			content='components',
			content_rowid='id'
		)
	`);

	const insert = db.prepare(`
		INSERT INTO components (name, category, type, description, init_signature, usage, body, keywords)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)
	`);

	const insertFts = db.prepare(`
		INSERT INTO components_fts (rowid, name, category, type, description, keywords, body)
		VALUES (?, ?, ?, ?, ?, ?, ?)
	`);

	const insertMany = db.transaction((entries) => {
		for (const e of entries) {
			const info = insert.run(e.name, e.category, e.type, e.description, e.initSignature, e.usage, e.body, e.keywords);
			insertFts.run(info.lastInsertRowid, e.name, e.category, e.type, e.description, e.keywords, e.body);
		}
	});

	insertMany(entries);

	const count = db.prepare('SELECT COUNT(*) as count FROM components').get();
	console.log(`Indexed ${count.count} components into ${DB_PATH}`);

	// Print categories
	const cats = db.prepare('SELECT DISTINCT category FROM components ORDER BY category').all();
	console.log(`Categories: ${cats.map(c => c.category).join(', ')}`);

	db.close();
}

// ── Main ────────────────────────────────────────────────────────────────────

const content = readFileSync(MD_PATH, 'utf-8');
const entries = parseComponentsMd(content);
console.log(`Parsed ${entries.length} entries from COMPONENTS.md`);
buildDatabase(entries);
