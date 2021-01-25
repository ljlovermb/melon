/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2020/12/30 18:41:19                          */
/*==============================================================*/


drop table if exists `isv_keys`;

drop table if exists `isv_list`;

drop table if exists `plugins`;

drop table if exists `service_instance`;

drop table if exists `service_route`;

drop table if exists `waf`;

drop table if exists `timer`;

/*==============================================================*/
/* Table: isv_keys                                              */
/*==============================================================*/
create table `isv_keys`
(
   `id`                  int not null auto_increment comment 'ID',
   `app_key`              varchar(128) not null default '' comment '应用键',
   `sign_type`            tinyint not null default 1 comment '1 - RSA,2 - AES,3 - MD5',
   `secret`               varchar(32) not null default '' comment '加密key(sign_type等于2,3时使用)',
   `isv_public_key`       text comment 'ISV公钥',
   `isv_private_key`      text comment 'ISV私钥',
   `platform_public_key`  text comment '平台公钥',
   `platform_private_key` text comment '平台私钥',
   `create_time`          datetime not null default CURRENT_TIMESTAMP comment '创建时间',
   `op_time`              timestamp not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP comment '最后一次修改时间',
   primary key (`id`),
   unique key `unique_key` (`app_key`)
);

alter table isv_keys comment 'ISV密钥列表';

/*==============================================================*/
/* Table: isv_list                                              */
/*==============================================================*/
create table isv_list
(
   `id`                   int not null auto_increment comment 'ID',
   `isv_name`             varchar(64) not null default '' comment 'ISV名称',
   `app_key`              varchar(128) not null default '' comment '应用键',
   `status`               tinyint not null default 0 comment '0 - 启用,1 - 禁用',
   `create_time`          datetime not null default CURRENT_TIMESTAMP comment '创建时间',
   `op_time`              timestamp not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP comment '最后一次修改时间',
   primary key (`id`)
);

alter table isv_list comment 'isv列表';

/*==============================================================*/
/* Table: plugins                                               */
/*==============================================================*/
create table `plugins`
(
   `id`                   int not null auto_increment,
   `key`                  varchar(255) not null default '',
   `value`                varchar(2048) not null default '',
   `type`                 varchar(16) not null default '',
   `op_time`              timestamp not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   primary key (`id`),
   unique key `unique_key` (`key`)
);

/*==============================================================*/
/* Table: service_instance                                      */
/*==============================================================*/
create table `service_instance`
(
    `id`                   int not null auto_increment,
    `key`                  varchar(255) not null default '',
    `value`                varchar(2048) not null default '',
    `type`                 varchar(16) not null default '',
    `op_time`              timestamp not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    primary key (`id`),
    unique key `unique_key` (`key`)
);


/*==============================================================*/
/* Table: service_route                                         */
/*==============================================================*/
create table `service_route`
(
    `id`                   int not null auto_increment,
    `key`                  varchar(255) not null default '',
    `value`                varchar(2048) not null default '',
    `type`                 varchar(16) not null default '',
    `op_time`              timestamp not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    primary key (`id`),
    unique key `unique_key` (`key`)
);

/*==============================================================*/
/* Table: waf                                                   */
/*==============================================================*/
create table `waf`
(
    `id`                   int not null auto_increment,
    `key`                  varchar(255) not null default '',
    `value`                varchar(2048) not null default '',
    `type`                 varchar(16) not null default '',
    `op_time`              timestamp not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    primary key (`id`),
    unique key `unique_key` (`key`)
);

/*==============================================================*/
/* Table: waf                                                   */
/*==============================================================*/
create table `timer`
(
    `id`                   int not null auto_increment,
    `key`                  varchar(255) not null default '',
    `value`                varchar(2048) not null default '',
    `type`                 varchar(16) not null default '',
    `op_time`              timestamp not null default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    primary key (`id`),
    unique key `unique_key` (`key`)
);

