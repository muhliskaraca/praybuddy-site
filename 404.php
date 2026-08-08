<?php
// Fallback for URLs that do not exist.
// Reason: on the likafilm subdomains All-Inkl ignores "ErrorDocument 404" and
// answers with HTTP 500. So .htaccess catches the request via mod_rewrite and
// this script sets the correct status itself.
http_response_code(404);
header('Content-Type: text/html; charset=UTF-8');
$page = __DIR__ . '/404.html';
if (is_readable($page)) {
    readfile($page);
} else {
    echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">'
       . '<title>Page not found</title></head><body>'
       . '<h1>Page not found</h1>'
       . '<p><a href="/">Back to Pray Buddy</a></p></body></html>';
}
