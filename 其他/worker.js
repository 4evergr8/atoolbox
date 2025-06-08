export default {
  async fetch(request, env) {
    return handleRequest(request, env);
  },
};

async function handleRequest(request, env) {
  const url = new URL(request.url);
  const path = url.pathname.split('/');

  // 设置 CORS 头
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",  // 允许任何来源
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS", // 允许的方法
    "Access-Control-Allow-Headers": "Content-Type", // 允许的请求头
  };

  // 处理 OPTIONS 请求（预检请求）
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: corsHeaders, // 添加 CORS 头
    });
  }

  if (request.method === 'POST' && path[1] === 'upload') {
    const response = await handleUpload(request, path[2], env);
    return new Response(response.body, { status: response.status, headers: corsHeaders });
  } else if (request.method === 'GET' && path[1] === 'download') {
    const response = await handleDownload(path[2], env);
    return new Response(response.body, { status: response.status, headers: corsHeaders });
  } else {
    return new Response('Not Found', { status: 404, headers: corsHeaders });
  }
}

async function handleUpload(request, key, env) {
  const formData = await request.formData();
  const file = formData.get('file');

  if (!file) {
    return new Response('No file uploaded', { status: 400 });
  }

  const MAX_FILE_SIZE = 3 * 1024 * 1024; // 3MB 限制

  if (file.size > MAX_FILE_SIZE) {
    return new Response('File too large. Maximum allowed size is 3MB.', { status: 413 });
  }

  const content = await file.arrayBuffer();
  const contentType = file.type || 'application/octet-stream';

  try {
    await env.R2_BUCKET.put(key, content, {
      httpMetadata: { contentType },
    });

    return new Response('Upload successful', { status: 200 });
  } catch (error) {
    return new Response(`Failed to upload: ${error.message}`, { status: 500 });
  }
}

async function handleDownload(key, env) {
  try {
    const object = await env.R2_BUCKET.get(key);

    if (!object) {
      return new Response('File not found', { status: 404 });
    }

    const headers = new Headers();
    headers.set('Content-Type', object.httpMetadata?.contentType || 'application/octet-stream');

    return new Response(object.body, { status: 200, headers });
  } catch (error) {
    return new Response(`Error retrieving file: ${error.message}`, { status: 500 });
  }
}
