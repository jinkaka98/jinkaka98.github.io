// Kiro Tools Patch — adds bridge endpoint + CORS + auth to 9Router
const fs = require('fs');
const path = require('path');
const os = require('os');

const serverPath = process.platform === 'win32'
  ? path.join(process.env.APPDATA || '', 'npm', 'node_modules', '9router', 'app', 'server.js')
  : (() => {
      const candidates = [
        path.join(os.homedir(), '.npm', 'node_modules', '9router', 'app', 'server.js'),
        '/usr/local/lib/node_modules/9router/app/server.js',
        '/usr/lib/node_modules/9router/app/server.js',
      ];
      for (const c of candidates) { if (fs.existsSync(c)) return c; }
      // Try npm root -g
      try {
        const root = require('child_process').execSync('npm root -g', { encoding: 'utf8' }).trim();
        return path.join(root, '9router', 'app', 'server.js');
      } catch (e) { return ''; }
    })();

if (!serverPath || !fs.existsSync(serverPath)) {
  console.error('ERROR: 9Router tidak ditemukan di', serverPath || '(unknown)');
  console.error('Pastikan 9Router sudah terinstall: npm install -g 9router');
  process.exit(1);
}

console.log('Found 9Router:', serverPath);

const content = fs.readFileSync(serverPath, 'utf8');
if (content.includes('kiro-bridge')) {
  console.log('Sudah di-patch sebelumnya! Tinggal restart 9Router.');
  process.exit(0);
}

// Backup
const backup = serverPath + '.backup';
if (!fs.existsSync(backup)) {
  fs.copyFileSync(serverPath, backup);
  console.log('Backup:', backup);
}

// Patch code — uses require that won't conflict with original server.js
const patch = `const _http=require("http"),_crypto=require("crypto"),_fs=require("fs"),_os=require("os"),_path=require("path");
const _kH='<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><scr'+'ipt>window.addEventListener("message",async function(e){if(!e.data||e.data.type!=="kiro-import")return;var token=e.data.token,id=e.data.id;try{var res=await fetch("/api/oauth/kiro/import",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({refreshToken:token})});var data=await res.json();if(res.ok&&data.success){e.source.postMessage({type:"kiro-result",id:id,status:"success",email:data.connection?.email||"ok"},"*")}else{var err=(data.error||"").toLowerCase();if(err.includes("duplicate")||err.includes("already")||err.includes("exists")){e.source.postMessage({type:"kiro-result",id:id,status:"skip",msg:"exists"},"*")}else{e.source.postMessage({type:"kiro-result",id:id,status:"fail",msg:data.error||"Unknown"},"*")}}}catch(ex){e.source.postMessage({type:"kiro-result",id:id,status:"fail",msg:ex.message},"*")}});window.parent.postMessage({type:"kiro-bridge-ready"},"*");<\\/scr'+'ipt></body></html>';
function _kT(){try{const d=process.platform==="win32"?_path.join(process.env.APPDATA||"","9router"):_path.join(_os.homedir(),".9router");const m=_fs.readFileSync(_path.join(d,"machine-id"),"utf8").trim();const s=_fs.readFileSync(_path.join(d,"auth","cli-secret"),"utf8").trim();return _crypto.createHash("sha256").update(m+"9r-cli-auth"+s).digest("hex").slice(0,16)}catch(e){return""}}
const _oc=_http.createServer;_http.createServer=function(...a){const sv=_oc.apply(this,a);const _ol=sv.listeners("request").slice();sv.removeAllListeners("request");sv.on("request",(req,res)=>{if(req.url==="/kiro-bridge.html"){res.writeHead(200,{"Content-Type":"text/html","Access-Control-Allow-Origin":"*"});res.end(_kH);return}if(req.url==="/api/oauth/kiro/import"&&req.method==="OPTIONS"){res.writeHead(204,{"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"POST,OPTIONS","Access-Control-Allow-Headers":"Content-Type,Authorization,x-api-key,x-9r-cli-token","Access-Control-Max-Age":"600"});res.end();return}if(req.url==="/api/oauth/kiro/import"&&req.method==="POST"){res.setHeader("Access-Control-Allow-Origin","*");const t=_kT();if(t)req.headers["x-9r-cli-token"]=t}for(const l of _ol)l.call(sv,req,res)});return sv};
`;

fs.writeFileSync(serverPath, patch + content);
console.log('');
console.log('BERHASIL! Sekarang restart 9Router:');
console.log('  1. Tutup 9Router (Ctrl+C)');
console.log('  2. Jalankan ulang: 9router');
console.log('  3. Buka Kiro Tools di browser');
