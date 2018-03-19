(function transformRow(source, target, map, log, isUpdate) {

    var operating_system = source.u_os_type.toString();

    //This if statement uses JavaScript regular expressions to search the operating system
    if ( operating_system.match(/linux/i) != null ){
        target.sys_class_name="cmdb_ci_linux_server";
    } else if ( operating_system.match(/win/i) != null ){
        target.sys_class_name="cmdb_ci_win_server";
    }

})(source, target, map, log, action==="update");