#! /usr/bin/env php
<?php

use Stash\Pool;
use Stash\Driver\FileSystem;
use GuzzleHttp\Client;

require('vendor/autoload.php');

$config = require("config.php");

$url = sprintf(
    'https://api.forecast.io/forecast/%s/%s,%s?units=%s',
    $config['key'],
    $config['latitude'],
    $config['longitude'],
    $config['units']
);

// Create the cache pool
$hash = hash('sha1', implode($config));
$pool = new Pool(new FileSystem());

// Attempt cache retreaval
$item = $pool->getItem($hash);
$json = $item->get();

if ($item->isMiss() === true)
{
    echo 'Downloaded JSON' . PHP_EOL;
    $client = new Client();
    $response = $client->get($url);
    $json = $response->json();
    $item->set($json, $config['ttl']);
}
else
{
    echo 'Loaded Cache' . PHP_EOL;
}

if ($argc === 2 && isset($argv[1]) === true)
{
    $argument = $argv[1];
    if (isset($json->{$argument}) === true)
    {
        if (is_string($json->{$argument}) === true)
        {
            echo $json->{$argument} . PHP_EOL;
            exit;
        }
    }
}

if ($argc === 3 && isset($argv[2]) === true)
{
    $argumentA = $argv[1];
    $argumentB = $argv[2];
    if (isset($json->{$argumentA}->{$argumentB}) === true)
    {
        if (is_string($json->{$argumentA}->{$argumentB}) === true)
        {
            echo $json->{$argumentA}->{$argumentB} . PHP_EOL;
            exit;
        }
    }
}