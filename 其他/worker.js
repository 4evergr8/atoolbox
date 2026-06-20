export default {
    async fetch(request, env) {
        return handleRequest(request, env);
    },
};

async function handleRequest(request, env) {
    const url = new URL(request.url);
    const path = url.pathname.split('/');

    const corsHeaders = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    };

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

async function handleUpload(request, key, env, corsHeaders) {
    const formData = await request.formData();
    const file = formData.get('file');
    if (!file) {
        return new Response('没有上传文件', { status: 400, headers: corsHeaders });
    }

    const MAX_FILE_SIZE = 5 * 1024 * 1024;
    if (file.size > MAX_FILE_SIZE) {
        return new Response('文件过大，最大允许 5MB', { status: 413, headers: corsHeaders });
    }

    const content = await file.arrayBuffer();

    const finalKey = `temp/${key}`;

    await env.R2_BUCKET.put(finalKey, content, {
        httpMetadata: {
            contentType: "image/png"
        }
    });

    return new Response('文件上传成功', { status: 200, headers: corsHeaders });
}

async function handleDownload(key, env, corsHeaders) {
    const finalKey = `temp/${key}`;
    const object = await env.R2_BUCKET.get(finalKey);

    if (!object) {
        return new Response('文件不存在', { status: 404, headers: corsHeaders });
    }

    const headers = new Headers(corsHeaders);

    headers.set('Content-Type', "image/png");

    return new Response(object.body, { status: 200, headers });
}