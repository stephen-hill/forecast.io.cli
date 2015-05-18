#! /usr/bin/env php
<?php

use Stash\Pool;
use Stash\Driver\FileSystem;
use GuzzleHttp\Client;
use Noodlehaus\Config;

require('vendor/autoload.php');

$configPath = getcwd() . '/config.php';
$config = new Config($configPath);

$url = sprintf(
    'https://api.forecast.io/forecast/%s/%s,%s?units=%s',
    $config->get('key'),
    $config->get('latitude'),
    $config->get('longitude'),
    $config->get('units')
);

// Create the cache pool
$hash = hash_file('sha1', $configPath);
$driver = new FileSystem();
$driver->setOptions(['path' => sys_get_temp_dir()]);
$pool = new Pool($driver);

// Attempt cache retreaval
$item = $pool->getItem($hash);
$json = $item->get();

if ($item->isMiss() === true)
{
    $client = new Client();
    $response = $client->get($url);
    $json = $response->json();
    $item->set($json, $config->get('ttl'));
}

$jsonPath = sys_get_temp_dir() . '/' . $hash . '.json';
file_put_contents($jsonPath, json_encode($json));
$forecast = new Config($jsonPath);

foreach ($argv as $k => $v)
{
    if ($k === 0) { continue; }

    echo $forecast->get($v, "Data for '{$v}' not found.") . PHP_EOL;
}