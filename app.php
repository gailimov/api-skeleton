<?php

declare(strict_types=1);

ini_set('display_errors', 'stderr');

use Spiral\Goridge\StreamRelay;
use Spiral\RoadRunner\{Worker, PSR7Client};

chdir(dirname(__DIR__));
require 'vendor/autoload.php';

$psr7 = new PSR7Client(new Worker(new StreamRelay(STDIN, STDOUT)));

$app = (function () {
    $container = require 'config/container.php';

    $app = $container->get(\Zend\Expressive\Application::class);
    $factory = $container->get(\Zend\Expressive\MiddlewareFactory::class);

    (require 'config/pipeline.php')($app, $factory, $container);
    (require 'config/routes.php')($app, $factory, $container);

    return $app;
})();

while ($request = $psr7->acceptRequest()) {
    try {
        $psr7->respond($app->handle($request));
    } catch (\Throwable $e) {
        error_log((string) $e);
        $psr7->getWorker()->error('Something went wrong');
    }
}
