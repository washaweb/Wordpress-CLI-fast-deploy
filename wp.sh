#!/bin/bash -e

NORMAL="\\033[0;39m"
RED="\\033[1;31m"
BLUE="\\033[1;34m"

clear

####### configuration ########

######## init #########

echo "================================================================="
echo " WordPress CLI Installer"
echo "================================================================="

init() {
  # accept user input for the databse name
  read -p "Database Name? : " SQLDB
  if [ "$SQLDB" == '' ]; then
    echo 'database name is needed'
    exit;
  fi

  # accept user input for the database user
  read -p "Database User Name default (root) ? : " SQLUSER
  SQLUSER=${SQLUSER:-root}
  echo $SQLUSER

  # accept user input for the database password
  read -p "Database User Password: " SQLPASS
  if [ "$SQLPASS" == '' ]; then
    echo 'Database User Password is needed'
    exit;
  fi

  # accept user input for the website url
  read -p "Website URL (no http://) (default: localhost)? : " URL
  URL=${URL:-"localhost"}
  echo $URL

  # accept user input for the website title
  read -p "Website title (default: Wordpress)?: " TITLE
  TITLE=${TITLE:-"Wordpress"}
  echo $TITLE

  # accept user input for the website baseline
  read -p "Website baseline (default: Un site wordpress) ?: " DESCR
  DESCR=${DESCR:-"Un site wordpress"}
  echo $DESCR

  # accept user input for the Wordpress user pseudo
  read -p "Admin pseudo (default Admin) ?: " ADMINPSEUDO
  ADMINPSEUDO=${ADMINPSEUDO:-Admin}
  echo $ADMINPSEUDO

  ADMINPASS=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)

  # accept user input for the Wordpress user email
  read -p "Admin email (default:user@yourdomain.com) ?: " ADMINEMAIL
  ADMINEMAIL=${ADMINEMAIL:-'user@yourdomain.com'}
  echo $ADMINEMAIL

  read -p "Wordpress table prefix (default: 'wp_'): " DBPREFIX
  DBPREFIX=${DBPREFIX:-wp_}
  echo $DBPREFIX

  #install Wordpress, theme, plugins... :
  while true; do
    clear
    echo "===================================="
    read -p "Run Wordpress Install? (Yy/Nn)" yn
    case $yn in
        [Yy]* ) wpinstall; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
  done
  
  #launch website
  while true; do
    read -p "Start gulp-bs task? (Yy/Nn)" yn
    case $yn in
        # OPTION 1 : 
        # npm install, browsersync conf edit
        # build, open folder in sublime,
        # serve live with gulp task :
        [Yy]* ) wpbuild; break;;
        #OPTION 2 :
        #run website in browser:
        [Nn]* ) wprun; break;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

######## init #########
#UTILS : createdb $DATABASE $USER $PASSWORD
createdb() {
  #./db.sh $SQLDB $SQLUSER $SQLPASS
  clear
  Q1="CREATE DATABASE IF NOT EXISTS $1;"
  Q2="GRANT USAGE ON *.* TO $2@localhost IDENTIFIED BY '$3';"
  Q3="GRANT ALL PRIVILEGES ON $1.* TO $2@localhost;"
  Q4="FLUSH PRIVILEGES;"
  SQL="${Q1}${Q2}${Q3}${Q4}"
  echo ""
  echo "*========================================================*"
  echo "*  Create DB $1 for user $2@localhost"
  echo "*========================================================*"
  echo ""
  echo "Please enter MySQL root user's password :"
  echo "-----------------------------------------"

  /Applications/MAMP/Library/bin/mysql --host=localhost -uroot -p -e "$SQL"
}

wpinstall() {
  
  while true; do
    read -p "Install ACF plugins? (Yy/Nn)" yn
    case $yn in
        [Yy]* ) ACF='yes'; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
  done

  while true; do
    read -p "Install Woocommerce plugin? (Yy/Nn)" yn
    case $yn in
        [Yy]* ) WOO='yes'; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
  done
  
  while true; do
    read -p "Install Member zone plugins? (Yy/Nn)" yn
    case $yn in
        [Yy]* ) MEMBER='yes'; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
  done
  
  #Create SQL Database / User
  createdb $SQLDB $SQLUSER $SQLPASS

  if [ ! -d "www" ]; then
    mkdir www
  fi

  cd www

  echo ""
  echo "*============================*"
  echo "*  Installing Wordpress      *"
  echo "*============================*"
  echo ""
  #download and install wordpress fr
  if [ ! -d "wp-config.php" ]; then
    wp core download --locale=fr_FR
    wp core config --dbname=$SQLDB --dbuser=$SQLUSER --dbpass=$SQLPASS --dbhost='127.0.0.1' --dbprefix=$DBPREFIX --extra-php <<PHP
define( 'WP_DEBUG', false );
define( 'FS_METHOD', 'direct' );
define( 'WP_POST_REVISIONS', 10 );
define( 'WP_MEMORY_LIMIT', '64M' );
PHP
  fi

  wp core install --url="$URL/" --title=$TITLE --admin_user=$ADMINPSEUDO --admin_password=$ADMINPASS --admin_email=$ADMINEMAIL
  
  #remove unused themes and files
  rm wp-config-sample.php
  #wp theme delete twentyfourteen
  wp theme delete twentyfifteen
  wp theme delete twentysixteen

  #delete hello and akismet plugins
  wp plugin delete akismet
  wp plugin delete hello
  
  #install commons plugins
  wp plugin install user-role-editor all-in-one-wp-migration regenerate-thumbnails black-studio-tinymce-widget responsive-lightbox woosidebars siteorigin-panels contact-form-7 flamingo all-in-one-wp-security-and-firewall mailchimp-for-wp wordpress-seo wordpress-importer --activate
  
  # run optional ACF
  if [ "$ACF" == 'yes' ]; then
    wp plugin install advanced-custom-fields advanced-custom-field-repeater-collapser advanced-custom-fields-table-field acf-image-crop-add-on acf-link-picker-field acf-link advanced-custom-fields-recaptcha-field --activate
  fi
  
  # run optional woocommerce
  if [ "$WOO" == 'yes' ]; then
    wp plugin install woocommerce --activate
  fi
  # run optional Member zone
  if [ "$MEMBER" == 'yes' ]; then
    wp plugin install wp-members hide-admin-bar-from-non-admins --activate
  fi

  #install plugins of my own
  if [ ! -d "wp-content/plugins/bootstrap4-shorcodes" ]; then
    git clone git@github.com:washaweb/bootstrap-shortcodes.git ./wp-content/plugins/bootstrap4-shorcodes
  fi

  if [ ! -d "wp-content/themes/understrap" ]; then
    git clone git@github.com:holger1411/understrap.git ./wp-content/themes/understrap
    git clone git@github.com:holger1411/understrap-child.git ./wp-content/themes/understrap-child
    wp theme activate understrap-child
  fi
  #finaly update all languages
  #wp language install en_US
  #wp language install de_DE
  wp core language update

  #import default data
  wp import ../data.xml --authors=create
  # activate primary menu
  wp menu location assign "Menu principal" primary
  
  # show only 6 posts on an archive page
  wp option update posts_per_page 6
  
  # remove allow comments
  wp option update default_comment_status 'closed'
  # set site description
  wp option update blogdescription "$DESCR"

  # set homepage as front page
  wp option update show_on_front 'page'
  # set homepage to be the page 'Accueil'
  wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=accueil --field=ID --format=ids)
  # set blogpage to be the page 'Blog'
  wp option update page_for_posts $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=blog --field=ID --format=ids)
  
  # set pretty urls
  wp option update permalink_structure '/%postname%/'
  wp rewrite structure '/%postname%/' --hard
  wp rewrite flush --hard
  cd ..
  #setpermissions :
  #wppermissions
  clear
  # copy password to clipboard
  echo $ADMINPASS | pbcopy
  
  echo ""
  echo " *===========================================*"
  echo " *                                           *"
  echo " *   Installation is complete                *"
  echo " *   Your username/password here :           *"
  echo " *   (Password copied to clipboard)          *"
  echo " *                                           *"
  echo " *      Username: $ADMINPSEUDO               *"
  echo " *      Password: $ADMINPASS                 *"
  echo " *                                           *"
  echo " *   You should now save permalinks          *"
  echo " *   to finish the installation.             *"
  echo " *                                           *"
  echo " ============================================*"
}

wppermissions() {
  echo ""
  echo "*==================================*"
  echo "*  Fix folder / files permissions  *"
  echo "*==================================*"
  sudo chown -R www-data:www-data ./www/
  sudo find ./www/ -type d -exec chmod g+s {} \;
  sudo chmod g+w ./www/wp-content
  sudo chmod -R g+w ./www/wp-content/themes
  sudo chmod -R g+w ./www/wp-content/plugins
  sudo chmod 644 ./www/wp-config.php
}


wpbuild () {
  echo ""
  echo "*===========================================*"
  echo "*  Launch gulp watch task with browsersync  *"
  echo "*===========================================*"
  cd www/wp-content/themes/understrap-child/
  npm install
  sed -i '.bak' "s/localhost\/understrap\//$URL\//g" gulpfile.js
  gulp watch-bs
  sublime .
  wprun
}

wprun() {
  echo ""
  echo "*===============================*"
  echo "*  open website in the browser  *"
  echo "*===============================*"
  open "http://$URL/wp-admin/options-permalink.php"
}

#launch init:
init

$*
