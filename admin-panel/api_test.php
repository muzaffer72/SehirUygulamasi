<?php
// API erişim testi script'i
header('Content-Type: application/json');

// Gönderilen veriler
$response = [
    'status' => 'success',
    'message' => 'API erişim testi başarılı',
    'timestamp' => date('Y-m-d H:i:s'),
    'data' => [
        'api_version' => '1.0',
        'endpoints' => [
            '/api/cities',
            '/api/districts',
            '/api/categories',
            '/api/posts',
            '/api/users'
        ]
    ]
];

echo json_encode($response);