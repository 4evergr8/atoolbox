export default {
  async fetch(request, env) {
    return handleRequest(request, env);
  },
};

async function handleRequest(request, env) {
  const url = new URL(request.url);
  const path = url.pathname.split('/');

  // 统一的跨域头
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",              // 允许所有来源
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS", // 允许的方法
    "Access-Control-Allow-Headers": "Content-Type",  // 允许的请求头
  };

  // 处理预检请求
  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    if (request.method === 'POST' && path[1] === 'upload') {
      return await handleUpload(request, path[2], env, corsHeaders);
    }
    if (request.method === 'GET' && path[1] === 'download') {
      return await handleDownload(path[2], env, corsHeaders);
    }
    return new Response('未找到接口', { status: 404, headers: corsHeaders });
  } catch (e) {
    return new Response(`服务器错误: ${e.message}`, { status: 500, headers: corsHeaders });
  }
}

// 上传文件
async function handleUpload(request, key, env, corsHeaders) {
  const formData = await request.formData();
  const file = formData.get('file');
  if (!file) {
    return new Response('没有上传文件', { status: 400, headers: corsHeaders });
  }

  // 限制最大文件大小 3MB
  const MAX_FILE_SIZE = 5 * 1024 * 1024;
  if (file.size > MAX_FILE_SIZE) {
    return new Response('文件过大，最大允许 5MB', { status: 413, headers: corsHeaders });
  }

  const content = await file.arrayBuffer();
  const contentType = file.type || 'application/octet-stream';

  await env.R2_BUCKET.put(key, content, { httpMetadata: { contentType } });
  return new Response('文件上传成功', { status: 200, headers: corsHeaders });
}

// 下载文件
async function handleDownload(key, env, corsHeaders) {
  const object = await env.R2_BUCKET.get(key);
  if (!object) {
    return new Response('文件不存在', { status: 404, headers: corsHeaders });
  }

  const headers = new Headers(corsHeaders);
  headers.set('Content-Type', object.httpMetadata?.contentType || 'application/octet-stream');
  headers.set('Content-Length', object.size);

  return new Response(object.body, { status: 200, headers });
}
