# typo3-base

* is a nginx base image
* uses php 8.3
* install npm & nodejs (even yarn but will be dropped in v4)
* includes some nginx configurations
  * sets security header 
  * zip certain file types
  * blocks external access to TYPO3 specific files
* uses logrotation (see [How to rotate TYPO3 log files](https://brot.krue.ml/how-to-rotate-typo3-log-files/))