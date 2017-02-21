<?php
// this script is a quick and dirty solution to create a user with quota set
// don't expect it to be secure - use it only with known input and at own risk!


function add_user($firstname, $lastname, $password, $quota = "100 MB")
{
        putenv("OC_PASS=$password");
        $username = strtolower(addslashes($firstname.'.'.$lastname));
        system("/usr/bin/php occ user:add --password-from-env --display-name \"". addslashes("$firstname $lastname")  ."\" -g group " . $username);
        system("/usr/bin/php occ user:setting $username files quota \"$quota\"");
        return null;
}

function gen_password($length = 20)
{
        $min = 0x20;
        $max = 0x7e;
        $ret = '';
        for ($i = 0; $i < $length; $i++) $ret .= chr(rand($min, $max));
        return $ret;
}

if (count($_SERVER["argv"]) != 3) die("Call this script with " . __FILE__ . " firstname lastname\n");

$pw = gen_password();
$first = $_SERVER["argv"][1];
$last = $_SERVER["argv"][2];
add_user($first, $last,$pw);
echo $pw."\n";
