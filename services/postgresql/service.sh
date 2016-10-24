#!/bin/bash

exec > >(tee -a /usr/local/osmosix/logs/postgresql_$$.log) 2>&1

OSSVC_HOME=/usr/local/osmosix/service
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. $OSSVC_HOME/utils/cfgutil.sh
. $OSSVC_HOME/utils/install_util.sh
. $OSSVC_HOME/utils/os_info_util.sh
. $OSSVC_HOME/utils/agent_util.sh

cmd=$1
SVCNAME="postgresql"
SVCHOME="$OSSVC_HOME/$SVCNAME"
USER_ENV="/usr/local/osmosix/etc/userenv"

case $cmd in
	install) # envs not available
	    yum install -y postgresql-server postgresql-contrib
		;;
	deploy)
	    postgresql-setup initdb
	    if [ -n "${dbFiles}" ]; then
	        psql -u $username -p${password} < ${dbFiles}
	    fi
		;;
	configure)
		log "[CONFIGURE] Configuring $SVCNAME"
		sed -i -e 's$127.0.0.1/32            ident$0.0.0.0/0               md5$g' /var/lib/pgsql/data/pg_hba.conf
		;;
	start)
		if [ ! -z "$cliqrUserScript" -a -f "$cliqrUserScript" ]; then
			log "[START] Invoking pre-start user script"
			$cliqrUserScript 1 $cliqrUserScriptParams
		fi

		log "[START] Starting $SVCNAME"

        systemctl start postgresql
        systemctl enable postgresql

		if [ ! -z $cliqrUserScript -a -f $cliqrUserScript ]; then
			log "[START] Invoking post-start user script"
			$cliqrUserScript 2 $cliqrUserScriptParams
		fi

		# Run restore script in case of migration
		if [ "$appMigrating" == "true" ]; then
				runMigrationRestoreScript
		fi
		log "[START] $SVCNAME successfully started."
		;;
	stop)
		log "[STOP] Invoking pre-stop user script"
		if [ ! -z $cliqrUserScript -a -f $cliqrUserScript ]; then
			$cliqrUserScript 3 $cliqrUserScriptParams
		fi

		log "[STOP] Stopping $SVCNAME"

		log "[STOP] Invoking post-stop user script"
		if [ ! -z $cliqrUserScript -a -f $cliqrUserScript ]; then
			$cliqrUserScript 4 $cliqrUserScriptParams
		fi
		log "[STOP] $SVCNAME successfully stopped."
		;;
	restart)
		log "[RESTART] Invoking pre-restart user script"
		if [ ! -z $cliqrUserScript -a -f $cliqrUserScript ]; then
			$cliqrUserScript 5 $cliqrUserScriptParams
		fi

		log "[RESTART] Restarting $SVCNAME"

		log "[RESTART] Invoking post-restart user script"
		if [ ! -z $cliqrUserScript -a -f $cliqrUserScript ]; then
			$cliqrUserScript 6 $cliqrUserScriptParams
		fi
		;;
	reload)
		log "[RELOAD] Invoking pre-reload user script"
		if [ ! -z $cliqrUserScript -a -f $cliqrUserScript ]; then
			$cliqrUserScript 7 $cliqrUserScriptParams
		fi

		log "[RELOAD] Reloding $SVCNAME settings"

		log "[RELOAD] Invoking post-reload user script"
		if [ ! -z $cliqrUserScript -a -f $cliqrUserScript ]; then
			$cliqrUserScript 8 $cliqrUserScriptParams
		fi
		log "[RELOAD] $SVCNAME successfully reloaded."
		;;
	cleanup)

		;;
	upgrade)
		log "[UPGRADE] Upgrading."
		;;
	*)
		log "[ERROR] unknown command"
		exit 127
		;;
esac