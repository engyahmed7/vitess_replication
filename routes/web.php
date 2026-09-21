<?php

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/vitess', function () {
    return DB::selectOne('
        SELECT
            DATABASE() AS database_name,
            @@hostname AS hostname,
            @@port AS port
    ');
});
