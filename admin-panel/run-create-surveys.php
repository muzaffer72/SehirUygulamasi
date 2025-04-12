<?php
// Anketler tablolarını oluştur
include_once 'create-survey-table.php';

// Kullanıcıyı anasayfaya yönlendir
header("Location: index.php?page=surveys");
exit;