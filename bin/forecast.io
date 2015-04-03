#! /usr/bin/env php
<?php

use Stash\Pool;
use Stash\Driver\FileSystem;
use GuzzleHttp\Client;

require('vendor/autoload.php');

$config = require("config.php");