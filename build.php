<?php
/**
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

// Support Zabbix 2.4 or later.

define('PATH_ZABBIX', getenv('PATH_ZABBIX'));

if (!is_dir(PATH_ZABBIX)) {
  die('ERROR: Zabbix path "'.PATH_ZABBIX.'" is not a directory! Please check the PATH_ZABBIX environment.');
}


require PATH_ZABBIX . '/include/defines.inc.php';


define('PATH_ZABBIX_API_CLASS_FILE', PATH_ZABBIX.'/include/classes/api/API.php');
if(!file_exists(PATH_ZABBIX_API_CLASS_FILE)) {
  die('ERROR: API class file "'.PATH_ZABBIX_API_CLASS_FILE.'" not found! Please check the PATH_ZABBIX_API_CLASS_FILE configuration constant');
}


define('PATH_ZABBIX_API_CLASSES_DIRECTORY', PATH_ZABBIX.'/include/classes/api/services');
if(!is_dir(PATH_ZABBIX_API_CLASSES_DIRECTORY)) {
  die('ERROR: API class directory "'.PATH_ZABBIX_API_CLASSES_DIRECTORY.'" not found!');
}


require PATH_ZABBIX_API_CLASS_FILE;
require PATH_ZABBIX.'/include/classes/core/CRegistryFactory.php';
require PATH_ZABBIX.'/include/classes/api/CApiServiceFactory.php';
require PATH_ZABBIX.'/include/classes/api/CApiService.php';


class ZabbixApiClassMap extends CApiServiceFactory {
  public function getClassMap() {
    $classMap = $this->objects;
    return $classMap;
  }
}


function __autoload($className) {
  require PATH_ZABBIX_API_CLASSES_DIRECTORY.'/'.$className.'.php';
}

require PATH_ZABBIX.'/include/classes/db/DB.php';
require PATH_ZABBIX.'/include/gettextwrapper.inc.php';
require PATH_ZABBIX.'/include/events.inc.php';
require PATH_ZABBIX.'/include/func.inc.php';

$apiArray = array();
$apiClassMap = new ZabbixApiClassMap();

foreach($apiClassMap->getClassMap() as $resource => $class) {
  // add resource to API array
  $apiArray[$resource] = array();

  // create new reflection class
  $ref = new ReflectionClass($class);

  $obj = $ref->newInstance();
  $refProp = new ReflectionProperty($class, 'getOptions');
  $refProp->setAccessible(true); // getOptions is protected.
  $getOptions = $refProp->getValue($obj);
  $apiArray[$resource]['getOptions'] = $getOptions;

  // loop through defined methods
  $apiArray[$resource]['methods'] = array();
  foreach($ref->getMethods(ReflectionMethod::IS_PUBLIC & ~ReflectionMethod::IS_STATIC) as $method) {
    // add action to API array
    if( $method->class != 'CZBXAPI'
      && !($resource == 'user' && $method->name == 'login')
      && !($resource == 'user' && $method->name == 'logout')
      && !$method->isConstructor()
      && !$method->isDestructor()
      && !$method->isAbstract()
      && !($method->name == 'pk')
      && !($method->name == 'pkOption')
      && !($method->name == 'tableName')
    ) {
      $apiArray[$resource]['methods'][] = $method->name;
    }
  }
}

printf("%s\n", json_encode($apiArray));
?>
