# Wordpress CLI fast deployment

Wordpress CLI fast deployment is a CLI script that runs Wordpress website in a minute with some defaults plugins/theme/addons and dummy data I've picked for you :

## Dependencies

The script is intend to run on a mac and needs a proper [MAMP](http://mamp.info) installation. It depends on [wp-cli](http://wp-cli.org/fr/), [nodejs](https://nodejs.org/en/) and [gulp](http://gulpjs.com).

Please refer to each project's documentation for further help.

## How to ?

Copy the scripts files `wp.sh` and `data.xml` in you server root folder and run this command line :

```bash
    ./wp.sh
```

After a couple of configuration prompts, the script will create a `www` folder and perform many default wordpress installations :

### createdb()

 - Create SQL database and USER to be used by your new wordpress website

### wpinstall()

 - Download, install and configure the latest version of Wordpress
 - Install the latest Understrap theme
 - Install the latest Understrap child-theme and activate this theme
 - Remove unused common Wordpress themes and plugins
 - Install, activate and use a collection of usefull plugins (see below for a list)
 - Import default menus, pages, articles and contact form from data.xml
 - Either launch website in your default browser *OR* start development script

### wpbuild()

 - Theme Development auto-start :
    * npm install
    * Browsersync autoconfiguration
    * Launch Gulp task and start edit your theme with SublimeText project already open at the right place

### wprun()

 - Launch website in the browser

After finishing the installation and loggin the admin, you should be redirected to the permalinks option page.
**Just save the permalink structure** of your brand new website and you're up to go !


#### theme in use

 - [understrap](https://github.com/holger1411/understrap)
 - [understrap-child](https://github.com/holger1411/understrap-child) (active theme)

#### installed plugin list

 - user-role-editor
 - all-in-one-wp-migration
 - regenerate-thumbnails
 - black-studio-tinymce-widget
 - responsive-lightbox
 - woosidebars
 - siteorigin-panels
 - contact-form-7
 - flamingo
 - all-in-one-wp-security-and-firewall
 - mailchimp-for-wp
 - wordpress-seo wordpress-importer
 - Bootstrap4-shortcodes

#### optional installed plugin list
 
Woocommerce :
 - woocommerce
 
ACF plugins :
 - advanced-custom-fields
 - advanced-custom-field-repeater-collapser
 - advanced-custom-fields-table-field
 - acf-image-crop-add-on
 - acf-link-picker-field
 - acf-link
 - advanced-custom-fields-recaptcha-field

Member zone plugins :
 - wp-members
 - hide-admin-bar-from-non-admins


