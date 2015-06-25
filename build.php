<?php
/**
 * This file based PhpZabbixApi/build.php.
 *
 * @file    build.php
 *
 * @brief   PHP script to build the PhpZabbixApi class(es).
 *
 * This file is part of PhpZabbixApi.
 *
 * PhpZabbixApi is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * PhpZabbixApi is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with PhpZabbixApi.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @copyright   GNU General Public License
 * @author      Skyarch Networks inc., confirm IT solutions GmbH, Rathausstrase 14, CH-6340 Baar
 */



// helper functions
function getProp($class, $prop_name) {
  $ref = new ReflectionClass($class);
  $refProp = new ReflectionProperty($class, $prop_name);

  $obj = $ref->newInstance();
  $refProp->setAccessible(true);
  return $refProp->getValue($obj);
}

function assert_path($path, $name) {
  if (is_dir($path) || file_exists($path)) { return; }

  fputs(STDERR, 'ERROR: "' .$path. '" is not a directory! Please check the ' .$name);
  die(1);
}


/*
 * Define some pathes and do some sanity checks for existence of the pathes.
 */

define('PATH_ZABBIX', getenv('PATH_ZABBIX'));
assert_path(PATH_ZABBIX, 'PATH_ZABBIX environment');

// load Zabbix internal constants, to access ZABBIX_API_VERSION
require PATH_ZABBIX . '/include/defines.inc.php';
$is_2_4_or_later = version_compare(ZABBIX_API_VERSION, '2.4') >= 0 ;

/**
 * @brief   Path to the API.php class file of the Zabbix PHP front-end.
 *
 * This class file will be used, to determine all available API classes.
 */
define('PATH_ZABBIX_API_CLASS_FILE', PATH_ZABBIX.'/include/classes/api/API.php');
assert_path(PATH_ZABBIX_API_CLASS_FILE, 'PATH_ZABBIX_API_CLASS_FILE');


/**
 * @brief   Path to the api/classes/ directory of the Zabbix PHP front-end.
 *
 * This directory and the contained class files will be used, to determine all
 * available methods for each API class.
 */
if($is_2_4_or_later) {
  define('PATH_ZABBIX_API_CLASSES_DIRECTORY', PATH_ZABBIX.'/include/classes/api/services');
} else {
  define('PATH_ZABBIX_API_CLASSES_DIRECTORY', PATH_ZABBIX.'/api/classes');
}

assert_path(PATH_ZABBIX_API_CLASSES_DIRECTORY, 'PATH_ZABBIX_API_CLASSES_DIRECTORY');



/*
 * Create class-map class.
 *
 * Create a new class and extend it from the origin Zabbix classes, so that we
 * can fetch the class map directly from the Zabbix classes without defining
 * it here.
 *
 * There are some differences between the Zabbix versions:
 *
 *  < 2.4:  The class map is stored as a static property directly in the
 *          origin API class.
 *
 *  >= 2.4: The class map is stored as an instance property in the
 *          origin CApiServiceFactory class.
 */

// load API
require PATH_ZABBIX_API_CLASS_FILE;
if ($is_2_4_or_later) {
  require PATH_ZABBIX.'/include/classes/core/CRegistryFactory.php';
  require PATH_ZABBIX.'/include/classes/api/CApiServiceFactory.php';
  require PATH_ZABBIX.'/include/classes/api/CApiService.php';


  class ZabbixApiClassMap extends CApiServiceFactory {
    public function getClassMap() {
      $classMap = $this->objects;
      return $classMap;
    }
  }
} else {
  require PATH_ZABBIX.'/include/classes/api/CZBXAPI.php';
  class ZabbixApiClassMap extends API
  {
    public function getClassMap()
    {
      return self::$classMap;
    }
  }
}


/*
 * Register SPL autoloader.
 *
 * The API class files always inherit from other classes. Most of the classes
 * inherit from the CZBXAPI class, but there are a bunch of classes which
 * are extended by other API classes.
 *
 * So that we don't have to "follow" the right order on loading API class files,
 * we're register an API autoloader right here.
 *
 * Later the get_class_methods() function will automatically invoke this
 * autoloader.
 */

function __autoload($className) {
  require PATH_ZABBIX_API_CLASSES_DIRECTORY.'/'.$className.'.php';
}

// require needed files for get properteis.
require PATH_ZABBIX.'/include/classes/db/DB.php';
require PATH_ZABBIX.'/include/gettextwrapper.inc.php';
require PATH_ZABBIX.'/include/events.inc.php';
require PATH_ZABBIX.'/include/func.inc.php';

// initialze API array
$apiArray = array();
// Create new instance for API class map.
$apiClassMap = new ZabbixApiClassMap();

// loop through class map
foreach($apiClassMap->getClassMap() as $resource => $class) {
  if ($class == 'CZBXAPI' || $class == 'CAPI' || $class == 'CApiService') { continue; }

  // add resource to API array
  $apiArray[$resource] = array();

  $apiArray[$resource]['getOptions'] = array_keys(getProp($class, 'getOptions'));
  $apiArray[$resource]['pk'] =         getProp($class, 'pk');


  // create new reflection class
  $ref = new ReflectionClass($class);
  // loop through defined methods
  $apiArray[$resource]['methods'] = array();
  foreach($ref->getMethods(ReflectionMethod::IS_PUBLIC & ~ReflectionMethod::IS_STATIC) as $method) {
    // add action to API array
    if(  $method->name != 'pk'
      && $method->name != 'pkOption'
      && $method->name != 'tableName'
      && !$method->isConstructor()
      && !$method->isDestructor()
      && !$method->isAbstract()
    ) {
      $apiArray[$resource]['methods'][] = strtolower($method->name);
    }
  }
}

$matches = array();
preg_match("/^(\d+\.\d+)\..+$/", ZABBIX_API_VERSION, $matches);
$version = $matches[1];

// Output APIs.
printf("%s\n", json_encode(array(
  'methods' => $apiArray,
  'version' => $version,
)));
?>
