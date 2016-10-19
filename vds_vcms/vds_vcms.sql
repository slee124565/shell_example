-- MySQL dump 10.16  Distrib 10.1.14-MariaDB, for osx10.11 (x86_64)
--
-- Host: localhost    Database: vcms
-- ------------------------------------------------------
-- Server version	10.1.14-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Ad_type`
--

DROP TABLE IF EXISTS `Ad_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Ad_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '类型编号',
  `name` varchar(255) DEFAULT NULL COMMENT '类型名称',
  `enable` int(11) DEFAULT '1' COMMENT '是否有效，1有效，2无效',
  `name_en` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Ad_type`
--

LOCK TABLES `Ad_type` WRITE;
/*!40000 ALTER TABLE `Ad_type` DISABLE KEYS */;
/*!40000 ALTER TABLE `Ad_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `advertisement_table`
--

DROP TABLE IF EXISTS `advertisement_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `advertisement_table` (
  `ad_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '广告id，自增',
  `db_id` varchar(255) DEFAULT NULL COMMENT '辨识结果id，有可能为空，表示用户自己在没有辨识结果的地方放了个广告',
  `job_id` int(11) DEFAULT NULL COMMENT '任务id',
  `frame` int(11) DEFAULT NULL COMMENT '广告出现时间',
  `cut_index` int(11) DEFAULT NULL COMMENT '与scene cut做外链时使用，用于统计吧。。。',
  `infowindow` varchar(255) DEFAULT NULL COMMENT 'vcms 播放器广告展示类型',
  `ad_type` int(11) DEFAULT NULL COMMENT 'katula那里的广告展示类型',
  `vast_url` varchar(2000) DEFAULT NULL COMMENT '用户设定的外链图片链接',
  `image` varchar(255) DEFAULT NULL COMMENT '用户上传的图片链接',
  `image_url` varchar(2000) DEFAULT NULL COMMENT '用户点击图片后跳转的链接，由用户自己设定',
  `text` text COMMENT '广告内容',
  `text_url` varchar(2000) DEFAULT NULL,
  `content` varchar(2000) DEFAULT NULL,
  `content_url` varchar(2000) DEFAULT NULL,
  `monitor` varchar(255) DEFAULT NULL,
  `_id` varchar(45) DEFAULT NULL COMMENT '广告在player json2里的id',
  `rect` varchar(45) DEFAULT NULL COMMENT '辨识结果的位置',
  `display` varchar(45) DEFAULT NULL COMMENT '广告是否展示',
  `create_time` int(11) DEFAULT NULL COMMENT '此条记录产生时间',
  `edit_time` int(11) DEFAULT NULL COMMENT '此条记录的编辑时间',
  `enable` int(11) DEFAULT NULL COMMENT '广告是否有效，1有效，0删除',
  `showBackground` varchar(45) DEFAULT NULL,
  `duration` int(45) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `is_people` int(11) DEFAULT NULL COMMENT '是否为人为添加红框',
  PRIMARY KEY (`ad_id`)
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advertisement_table`
--

LOCK TABLES `advertisement_table` WRITE;
/*!40000 ALTER TABLE `advertisement_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `advertisement_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `analysis_job`
--

DROP TABLE IF EXISTS `analysis_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analysis_job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL DEFAULT '0' COMMENT '视频学习的job_id',
  `frame` int(11) DEFAULT NULL COMMENT '物件出現在哪一個frame中( 1500ms, 表示出現在影片第1500ms上)',
  `image_name` varchar(255) DEFAULT NULL COMMENT '物件被切割出來的檔名, 可利用 http://vds.viscovery.co/image/xxx.png 取得	',
  `position` varchar(20) DEFAULT NULL COMMENT '物件出現的位置[x,y,w,h]',
  `vds_id` varchar(10) DEFAULT NULL COMMENT '物件所屬的品牌編號',
  `name` varchar(255) DEFAULT NULL COMMENT '物件名稱',
  `brand_code` varchar(5) DEFAULT NULL COMMENT '物件所屬的品牌編號',
  `track_id` varchar(30) DEFAULT NULL COMMENT '追蹤/群組編號 0:沒有被列入追蹤/群組中',
  `start_time` double(13,0) DEFAULT NULL COMMENT '物件開始分析的時間',
  `update_time` double(13,0) DEFAULT NULL COMMENT '物件分析完成的時間',
  `editer` int(11) DEFAULT '0',
  `brand_name` varchar(255) DEFAULT NULL COMMENT 'brand 的中文名',
  `is_valid` int(11) DEFAULT NULL,
  `class_name` varchar(255) DEFAULT NULL,
  `class_name_en` varchar(255) DEFAULT NULL,
  `brand_name_en` varchar(255) DEFAULT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `rate` float DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `analysis_job_jobid` (`job_id`),
  KEY `analysis_job_classname` (`class_name`),
  KEY `analysis_job_isvalid` (`is_valid`),
  KEY `analysis_job_vds_id` (`vds_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2190954 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `analysis_job`
--

LOCK TABLES `analysis_job` WRITE;
/*!40000 ALTER TABLE `analysis_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `analysis_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hrs_account`
--

DROP TABLE IF EXISTS `hrs_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hrs_account` (
  `account_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `username` varchar(12) NOT NULL,
  `password` varchar(64) NOT NULL,
  `role` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '0离线，1在线',
  `create_time` int(10) unsigned NOT NULL,
  `update_time` int(10) DEFAULT NULL,
  `is_job` tinyint(1) DEFAULT '1' COMMENT '是否在职，1在职，0离职',
  PRIMARY KEY (`account_id`),
  KEY `username` (`username`),
  KEY `password` (`password`),
  KEY `account_id` (`account_id`),
  KEY `email` (`email`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hrs_account`
--

LOCK TABLES `hrs_account` WRITE;
/*!40000 ALTER TABLE `hrs_account` DISABLE KEYS */;
/*!40000 ALTER TABLE `hrs_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hrs_brand`
--

DROP TABLE IF EXISTS `hrs_brand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hrs_brand` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vds_id` varchar(255) NOT NULL,
  `vds_name` varchar(255) NOT NULL,
  `brand_name` varchar(255) NOT NULL,
  `create_time` int(11) NOT NULL,
  `hrs_aid` int(11) NOT NULL,
  `name_zh_cn` varchar(255) DEFAULT NULL,
  `name_zh_tw` varchar(255) DEFAULT NULL,
  `name_en_us` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=304 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hrs_brand`
--

LOCK TABLES `hrs_brand` WRITE;
/*!40000 ALTER TABLE `hrs_brand` DISABLE KEYS */;
/*!40000 ALTER TABLE `hrs_brand` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hrs_job`
--

DROP TABLE IF EXISTS `hrs_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hrs_job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL DEFAULT '0' COMMENT '视频学习的job_id',
  `frame` int(11) DEFAULT NULL COMMENT '物件出現在哪一個frame中( 1500ms, 表示出現在影片第1500ms上)',
  `image_name` varchar(255) DEFAULT NULL COMMENT '物件被切割出來的檔名, 可利用 http://vds.viscovery.co/image/xxx.png 取得	',
  `position` varchar(20) DEFAULT NULL COMMENT '物件出現的位置[x,y,w,h]',
  `vds_id` varchar(10) DEFAULT NULL COMMENT '物件所屬的品牌編號',
  `name` varchar(255) DEFAULT NULL COMMENT '物件名稱',
  `brand_code` varchar(5) DEFAULT NULL COMMENT '物件所屬的品牌編號',
  `track_id` varchar(30) DEFAULT NULL COMMENT '追蹤/群組編號 0:沒有被列入追蹤/群組中',
  `editer` int(10) DEFAULT NULL COMMENT 'HRS人员',
  `start_time` double(13,0) DEFAULT NULL COMMENT '物件開始分析的時間',
  `update_time` double(13,0) DEFAULT NULL COMMENT '物件分析完成的時間',
  `brand_name` varchar(255) DEFAULT NULL COMMENT 'brand 的中文名',
  `is_valid` int(11) DEFAULT '1' COMMENT '1.rec正确 2.rec非选中 3.hrs验证rec正确 4.hrs重新修改 5.hrs非选中 6.hrs删除',
  `class_name` varchar(255) DEFAULT NULL,
  `class_name_en` varchar(255) DEFAULT NULL,
  `brand_name_en` varchar(255) DEFAULT NULL,
  `name_en` varchar(255) DEFAULT NULL,
  `rate` float DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `hrs_job_jobid` (`job_id`),
  KEY `hrs_job_classname` (`class_name`),
  KEY `hrs_job_isvalid` (`is_valid`),
  KEY `hrs_job_vds_brand` (`vds_id`,`brand_code`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2314458 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hrs_job`
--

LOCK TABLES `hrs_job` WRITE;
/*!40000 ALTER TABLE `hrs_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `hrs_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_status`
--

DROP TABLE IF EXISTS `job_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '只是用于自增的主键，避免job_id=-1时主键重复',
  `vds_job_id` int(11) NOT NULL COMMENT 'vds分析的job id，job_id = 0时，为未提交的job',
  `vid` int(11) NOT NULL COMMENT 'video 本身的id',
  `status` int(11) NOT NULL COMMENT ' -1:err, 1: job_initial, 3: vds_end, 5: hrs_end, ',
  `update_time` int(11) NOT NULL COMMENT '最后更新时间',
  `start_time` int(11) NOT NULL COMMENT '任务initial时间',
  `vds_submit_time` int(11) DEFAULT NULL COMMENT '提交至vds的时间',
  `analysis_category` text COMMENT '辨识分析类型，记录vdsid，半角逗号分隔',
  `analysis_level` int(11) DEFAULT NULL COMMENT '分析级别，1.到vds分析完成为止，2. 到hrs分析完成为止，3. 到hrs editor确认为止',
  `video_url` varchar(255) DEFAULT NULL COMMENT 'video保存在七牛的文件的hash值',
  `vds_status` int(11) DEFAULT NULL COMMENT 'vds 状态，0. 未完成，1. 完成，2. 失败',
  `hrs_status` int(11) DEFAULT NULL COMMENT 'hrs 状态，0. 未完成，1.完成，2.失败 ',
  `editor_status` int(11) DEFAULT NULL COMMENT '保留字段，记录HRS editor的反馈，0.未定义，1. 通过，2. 未通过',
  `vds_json` varchar(255) DEFAULT NULL COMMENT 'vds机器辨识的json保存的路径',
  `hrs_json` varchar(255) DEFAULT NULL COMMENT 'hrs辨识结果的json文件路径',
  `player_json` varchar(255) DEFAULT NULL COMMENT 'player能用的json文件路径',
  `err_msg` varchar(255) DEFAULT NULL COMMENT '错误信息，只需要记录一次',
  `replaced_job_id` int(11) DEFAULT NULL COMMENT '替换掉的job_id 默认为0',
  `fps` int(11) DEFAULT NULL COMMENT '每秒切的帧数，默认为1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6390 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_status`
--

LOCK TABLES `job_status` WRITE;
/*!40000 ALTER TABLE `job_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `account` varchar(255) NOT NULL COMMENT '用户名, （邮箱格式）',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `max_num_of_videos` int(10) NOT NULL COMMENT '用户最大可上传视频数',
  `max_video_length` int(11) DEFAULT '120' COMMENT '上传的最大视频长度，单位分钟',
  `token` varchar(32) DEFAULT NULL COMMENT '用户提交视频时用到的token',
  `start_time` int(11) NOT NULL COMMENT '使用权限起始时间',
  `end_time` int(11) NOT NULL COMMENT '使用权限终止时间',
  `search` varchar(50) DEFAULT NULL COMMENT '预留。。。',
  `hrs_role` tinyint(4) DEFAULT NULL COMMENT 'hrs权限，0:只经过机器辨识，1:经过HRS辨识，2:经过HRS Editor校正。',
  `sys_roles_level` tinyint(4) DEFAULT NULL COMMENT '用户等级:1 default, 2 admin, 3 it, 4 test',
  `status` tinyint(4) DEFAULT NULL COMMENT '账户受否正在使用：1 stop（到期）， 2 running， 3 block',
  `number_videos` int(10) DEFAULT NULL COMMENT '账户下视频数',
  `generate_api_key` tinyint(2) DEFAULT NULL,
  `db_settings` tinyint(4) DEFAULT NULL COMMENT '1 internal , 2 external, 3 customer',
  `api_settings` varchar(255) DEFAULT NULL COMMENT '预留',
  `creator_account` int(10) DEFAULT NULL,
  `analysed_space` decimal(10,0) DEFAULT NULL COMMENT '预留: 视频存储空间',
  `regist_time` int(11) DEFAULT NULL COMMENT '注册时间',
  `regist_ip` int(10) DEFAULT NULL COMMENT '注册ip',
  `rec_level` varchar(255) DEFAULT '1:1;2:1;3:1;4:1;5:1;6:1;7:1',
  `rec_priority` int(10) DEFAULT '1',
  `fps` int(10) DEFAULT '2',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `account` (`account`)
) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member`
--

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (1,'admin@viscovery.co','218ac85d26e447cc58b28ba1826308b5',100,120,'rqwerqwer',1446884752,1499884752,NULL,1,1,2,87,NULL,NULL,'',NULL,NULL,1446884752,NULL,'1:1;2:1;3:1;4:1;5:1;6:1;7:1',1,2);
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member_signlog`
--

DROP TABLE IF EXISTS `member_signlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `member_signlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `login_ip` int(10) DEFAULT NULL,
  `login_time` int(11) NOT NULL,
  `logout_time` int(11) DEFAULT NULL,
  `user_agent` varchar(128) NOT NULL,
  `create_time` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6246 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member_signlog`
--

LOCK TABLES `member_signlog` WRITE;
/*!40000 ALTER TABLE `member_signlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `member_signlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message` (
  `id` int(11) NOT NULL,
  `msg` varchar(255) NOT NULL,
  `create_time` int(11) NOT NULL,
  `member_id` int(11) NOT NULL,
  `is_delete` int(11) DEFAULT NULL,
  `is_read` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message`
--

LOCK TABLES `message` WRITE;
/*!40000 ALTER TABLE `message` DISABLE KEYS */;
/*!40000 ALTER TABLE `message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operation_review`
--

DROP TABLE IF EXISTS `operation_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operation_review` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time_start` int(11) DEFAULT NULL,
  `time_end` int(11) DEFAULT NULL,
  `accumulate_accounts` int(11) DEFAULT NULL,
  `total_video_count` int(11) DEFAULT NULL,
  `date_str` varchar(16) DEFAULT NULL,
  `total_minutes` int(11) DEFAULT NULL,
  `total_face_minutes` int(11) DEFAULT NULL,
  `total_object_minutes` int(11) DEFAULT NULL,
  `total_scene_minutes` int(11) DEFAULT NULL,
  `total_rec` int(11) DEFAULT NULL,
  `total_face` int(11) DEFAULT NULL,
  `total_object` int(11) DEFAULT NULL,
  `total_scene` int(11) DEFAULT NULL,
  `total_right_face` int(11) DEFAULT NULL,
  `total_right_object` int(11) DEFAULT NULL,
  `total_right_scene` int(11) DEFAULT NULL,
  `total_wrong_face` int(11) DEFAULT NULL,
  `total_wrong_object` int(11) DEFAULT NULL,
  `total_wrong_scene` int(11) DEFAULT NULL,
  `total_untrain_face` int(11) DEFAULT NULL,
  `total_untrain_object` int(11) DEFAULT NULL,
  `total_untrain_scene` int(11) DEFAULT NULL,
  `face_time_use` int(11) DEFAULT NULL,
  `object_time_use` int(11) DEFAULT NULL,
  `scene_time_use` int(11) DEFAULT NULL,
  `hrs_time_use` int(11) DEFAULT NULL,
  `vds_time_use` int(11) DEFAULT NULL,
  `hrs_video_time` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=796 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operation_review`
--

LOCK TABLES `operation_review` WRITE;
/*!40000 ALTER TABLE `operation_review` DISABLE KEYS */;
/*!40000 ALTER TABLE `operation_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scene_cut`
--

DROP TABLE IF EXISTS `scene_cut`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scene_cut` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '一行的主键',
  `cut_index` int(11) DEFAULT NULL COMMENT 'scene_cut中每一笔任务里的 一段时间的 唯一标识',
  `start_time` int(11) DEFAULT NULL COMMENT '一段时间的开始时间',
  `duration` int(11) DEFAULT NULL COMMENT '持续时间',
  `end_time` int(11) DEFAULT NULL COMMENT '结束时间 = start_time + duration\n',
  `vid` int(11) DEFAULT NULL COMMENT '影片id',
  `job_id` int(11) DEFAULT NULL COMMENT '任务id',
  `create_time` int(11) DEFAULT NULL COMMENT '当前行数据创建时间',
  `ad_type` varchar(255) DEFAULT NULL COMMENT '可以投放的广告类型，外链到Ad_type表',
  `enable` int(11) DEFAULT '1' COMMENT '是否有效，1有效，2无效',
  `ad_type_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `ad_type_name_en` varchar(255) DEFAULT NULL,
  `update_time` int(11) DEFAULT NULL,
  `source` int(11) DEFAULT '1' COMMENT '1 rec过scene_cut的结果  2 hrs过scene_cut的结果   3 editor',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=97866 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scene_cut`
--

LOCK TABLES `scene_cut` WRITE;
/*!40000 ALTER TABLE `scene_cut` DISABLE KEYS */;
/*!40000 ALTER TABLE `scene_cut` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scene_parse_job`
--

DROP TABLE IF EXISTS `scene_parse_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scene_parse_job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `update_time` int(11) DEFAULT NULL,
  `cut_index` int(11) DEFAULT NULL COMMENT '每个job_id中的广告机会',
  `frame_start` int(11) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `vds_id` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `class_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `class_name_en` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `brand_code` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `brand_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `brand_name_en` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `stat_score` float DEFAULT NULL,
  `enable` int(11) DEFAULT '1',
  `cut_score` float DEFAULT '1',
  `screen_ratio` float DEFAULT NULL,
  `source` int(11) DEFAULT '1' COMMENT '1 rec经过scene_cut的结果　2hrs过scene_cut的结果　３editor',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=57526 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scene_parse_job`
--

LOCK TABLES `scene_parse_job` WRITE;
/*!40000 ALTER TABLE `scene_parse_job` DISABLE KEYS */;
/*!40000 ALTER TABLE `scene_parse_job` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_roles`
--

DROP TABLE IF EXISTS `sys_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sys_roles` (
  `level` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'level权限:1 default, 2 admin, 3 it, 4 test',
  `create_time` int(11) NOT NULL COMMENT '生成时间',
  `update_time` int(11) NOT NULL COMMENT '修改时间',
  `sys_tag_ids` varchar(64) DEFAULT NULL COMMENT '权限tag，可以使用的页面',
  `status` int(11) DEFAULT NULL COMMENT '是否显示',
  `level_name` varchar(32) DEFAULT NULL COMMENT '权限名称',
  `control_level` varchar(255) DEFAULT NULL,
  `can_view` int(11) DEFAULT '1' COMMENT '可以看谁的账号，1.只能看到自己，2.可以看到子账号，3.看到全部账号',
  PRIMARY KEY (`level`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_roles`
--

LOCK TABLES `sys_roles` WRITE;
/*!40000 ALTER TABLE `sys_roles` DISABLE KEYS */;
INSERT INTO `sys_roles` VALUES (1,1446792973,1446792973,'1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,18',1,'admin','2,3',3),(2,1446792973,1446792973,'1,2,3,4,5,6,7,8,14,18',1,'IT','3',2),(3,1446792973,1446792973,'5,6,8,14',1,'default',NULL,1);
/*!40000 ALTER TABLE `sys_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_tag`
--

DROP TABLE IF EXISTS `sys_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sys_tag` (
  `tag_id` smallint(6) NOT NULL COMMENT '权限id',
  `name` varchar(32) DEFAULT NULL COMMENT '权限名称',
  `parent_id` smallint(6) DEFAULT NULL COMMENT '父权限id',
  `create_time` int(11) DEFAULT NULL,
  `status` tinyint(1) DEFAULT NULL COMMENT '是否显示',
  `description` varchar(255) DEFAULT NULL COMMENT '描述信息',
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_tag`
--

LOCK TABLES `sys_tag` WRITE;
/*!40000 ALTER TABLE `sys_tag` DISABLE KEYS */;
INSERT INTO `sys_tag` VALUES (0,'Advertisment',0,NULL,1,'广告搜索',NULL),(1,'Account',0,1446792973,1,'账户',NULL),(2,'New Account',1,1446792973,1,'新增账户','Account/new-account'),(3,'Account Process',1,1446792973,1,'账户管理','Account/account-process'),(4,'Account Api',1,1446792973,1,'账户api文档','Account/api-document'),(5,'Video',0,1446792973,1,'视频',NULL),(6,'Video Manager',5,1446792973,1,'视频界面','Video/user-interface'),(7,'Video Board',5,1446792973,1,'视频管理','Video/video-board'),(8,'Report',0,1446792973,1,'',''),(9,'BI',0,1446792973,1,'',NULL),(10,'Edit Level',1,1446792973,1,'账户权限修改',NULL),(11,'Ad',0,1446792973,1,'广告',NULL),(12,'Ad Opportunity',11,1446792973,1,'广告统计','Advertisment/view'),(13,'Edit Tag',5,NULL,1,'审查hrs结果',NULL),(14,'Tag',8,NULL,1,'报表','Report/'),(15,'Operational Review',1,NULL,1,'辨识系统统计','Account/operational-review'),(16,'Demo Player',0,NULL,1,'展示页',NULL),(17,'demo player',16,NULL,1,'展示页','Demo/Player'),(18,'Video Name',8,NULL,NULL,'报表','Report/Report_video');
/*!40000 ALTER TABLE `sys_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `video_folder`
--

DROP TABLE IF EXISTS `video_folder`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `video_folder` (
  `folder_id` int(11) NOT NULL AUTO_INCREMENT,
  `folder_name` varchar(255) CHARACTER SET utf8 NOT NULL COMMENT '名称',
  `parent_folder_id` int(11) NOT NULL DEFAULT '0' COMMENT '默认在根目录下，根目录不在表中保存',
  `member_id` int(11) NOT NULL COMMENT '目录属于谁',
  `status` int(11) DEFAULT '1' COMMENT '1.使用中 2.停用（删除）',
  `create_time` int(11) NOT NULL DEFAULT '0' COMMENT '创建时间',
  `update_time` int(11) NOT NULL DEFAULT '0' COMMENT '更新时间',
  PRIMARY KEY (`folder_id`)
) ENGINE=InnoDB AUTO_INCREMENT=356 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_folder`
--

LOCK TABLES `video_folder` WRITE;
/*!40000 ALTER TABLE `video_folder` DISABLE KEYS */;
INSERT INTO `video_folder` VALUES (1,'未归档视频',0,1,1,0,0),(165,'未归档视频',0,19,1,0,0),(166,'未归档视频',0,20,1,0,0),(167,'未归档视频',0,21,1,0,0),(168,'未归档视频',0,22,1,0,0),(169,'未归档视频',0,23,1,0,0),(170,'未归档视频',0,24,1,0,0),(171,'未归档视频',0,25,1,0,0),(172,'未归档视频',0,26,1,0,0),(173,'未归档视频',0,27,1,0,0),(174,'未归档视频',0,28,1,0,0),(175,'未归档视频',0,29,1,0,0),(176,'未归档视频',0,30,1,0,0),(177,'未归档视频',0,31,1,0,0),(178,'未归档视频',0,32,1,0,0),(179,'未归档视频',0,33,1,0,0),(180,'未归档视频',0,34,1,0,0),(181,'未归档视频',0,35,1,0,0),(182,'未归档视频',0,36,1,0,0),(183,'未归档视频',0,37,1,0,0),(184,'未归档视频',0,38,1,0,0),(185,'未归档视频',0,39,1,0,0),(186,'未归档视频',0,40,1,0,0),(187,'未归档视频',0,41,1,0,0),(188,'未归档视频',0,42,1,0,0),(189,'未归档视频',0,43,1,0,0),(190,'未归档视频',0,44,1,0,0),(191,'未归档视频',0,45,1,0,0),(192,'未归档视频',0,46,1,0,0),(193,'未归档视频',0,47,1,0,0),(194,'未归档视频',0,48,1,0,0),(195,'未归档视频',0,49,1,0,0),(196,'未归档视频',0,50,1,0,0),(197,'未归档视频',0,51,1,0,0),(198,'未归档视频',0,52,1,0,0),(199,'未归档视频',0,53,1,0,0),(200,'未归档视频',0,54,1,0,0),(201,'未归档视频',0,55,1,0,0),(202,'未归档视频',0,56,1,0,0),(203,'未归档视频',0,57,1,0,0),(204,'未归档视频',0,58,1,0,0),(205,'未归档视频',0,59,1,0,0),(206,'未归档视频',0,60,1,0,0),(207,'未归档视频',0,61,1,0,0),(208,'未归档视频',0,62,1,0,0),(209,'未归档视频',0,63,1,0,0),(210,'未归档视频',0,64,1,0,0),(211,'未归档视频',0,65,1,0,0),(212,'未归档视频',0,66,1,0,0),(213,'未归档视频',0,67,1,0,0),(214,'未归档视频',0,68,1,0,0),(215,'未归档视频',0,69,1,0,0),(216,'未归档视频',0,70,1,0,0),(217,'未归档视频',0,71,1,0,0),(218,'未归档视频',0,72,1,0,0),(219,'未归档视频',0,73,1,0,0),(220,'未归档视频',0,74,1,0,0),(221,'未归档视频',0,75,1,0,0),(222,'未归档视频',0,76,1,0,0),(223,'未归档视频',0,77,1,0,0),(224,'未归档视频',0,78,1,0,0),(225,'未归档视频',0,79,1,0,0),(226,'未归档视频',0,80,1,0,0),(227,'未归档视频',0,81,1,0,0),(228,'未归档视频',0,82,1,0,0),(229,'未归档视频',0,84,1,0,0),(230,'未归档视频',0,85,1,0,0),(231,'未归档视频',0,86,1,0,0),(232,'未归档视频',0,87,1,0,0),(233,'未归档视频',0,88,1,0,0),(234,'未归档视频',0,89,1,0,0),(235,'未归档视频',0,90,1,0,0),(236,'未归档视频',0,91,1,0,0),(237,'未归档视频',0,92,1,0,0),(238,'未归档视频',0,93,1,0,0),(239,'未归档视频',0,94,1,0,0),(240,'未归档视频',0,95,1,0,0),(241,'未归档视频',0,96,1,0,0),(242,'未归档视频',0,97,1,0,0),(243,'未归档视频',0,98,1,0,0),(244,'未归档视频',0,99,1,0,0),(245,'未归档视频',0,100,1,0,0),(246,'未归档视频',0,101,1,0,0),(247,'未归档视频',0,102,1,0,0),(248,'未归档视频',0,103,1,0,0),(249,'未归档视频',0,104,1,0,0),(250,'未归档视频',0,105,1,0,0),(251,'未归档视频',0,106,1,0,0),(252,'未归档视频',0,107,1,0,0),(253,'未归档视频',0,108,1,0,0),(254,'未归档视频',0,109,1,0,0),(255,'未归档视频',0,110,1,0,0),(256,'未归档视频',0,111,1,0,0),(292,'test',0,52,2,1461918356,1461918393),(293,'12',0,49,2,1461918445,1461919052),(294,'test',0,49,2,1461918974,1461919043),(295,'13',0,49,2,1461918974,1461919251),(296,'f2',0,49,2,1461919319,1461921113),(297,'we',0,20,2,1461919908,1462354398),(298,'test1',0,52,1,1461922694,1461922694),(299,'test3',0,52,2,1461922708,1461925683),(300,'测试',0,25,2,1461923786,1461923795),(301,'test',0,52,2,1461925662,1461925673),(302,'2016.05.02~05.08',0,106,1,1462277532,1462277532),(303,'fin4',0,20,2,1462354115,1462354261),(304,'te3',0,20,2,1462354252,1462354267),(305,'te',0,20,2,1462355442,1462355446),(306,'广告demo',0,69,2,1462859371,1462951002),(307,'Demo',0,100,2,1462946917,1462946954),(308,'未归档视频',0,112,1,1462946917,1462946917),(309,'test',0,69,2,1463127525,1463463506),(310,'2016.05.09~05.15',0,106,1,1463146782,1463146782),(311,'未归档视频',0,113,1,1463146782,1463146782),(312,'电视剧',0,112,1,1463369026,1463369026),(313,'dddd ',0,49,2,1463377044,1463377218),(314,'ccccccccccccccccssssssssss',0,49,2,1463377256,1463377330),(315,'cccccccccccccccccccccccccvvvbbfffff',0,49,2,1463543861,1463659757),(316,'hello',0,49,2,1463550007,1463659746),(317,'world',0,49,1,1463659739,1463659739),(318,'欢乐颂',0,49,1,1463720597,1463720597),(319,'屌丝男士',0,113,1,1463734945,1463734945),(320,'未归档视频',0,115,1,1463734945,1463734945),(321,'未归档视频',0,116,1,1464075592,1464075592),(322,'未归档视频',0,117,1,1464148336,1464148336),(323,'未归档视频',0,118,1,1464148386,1464148386),(324,'欢乐颂',0,117,1,1464151772,1464151772),(325,'欢乐颂',0,118,1,1464151812,1464151812),(326,'欢乐颂',0,113,1,1464227794,1464227794),(327,'test',0,69,1,1464251995,1464251995),(328,'未归档视频',0,119,1,1464319954,1464319954),(329,'未归档视频',0,120,1,1464596196,1464596196),(330,'未归档视频',0,121,1,1464661703,1464661703),(331,'他来了请闭眼',0,113,1,1464771934,1464771934),(332,'我是杜拉拉',0,113,1,1464772653,1464772672),(333,'未归档视频',0,122,1,1464832895,1464832895),(334,'未归档视频',0,123,1,1464832945,1464832945),(335,'未归档视频',0,124,1,1464832966,1464832966),(336,'屌丝男士',0,124,1,1464837582,1464837582),(337,'我是杜拉拉',0,122,1,1464837629,1464837629),(338,'他来了，请闭眼',0,123,1,1464837659,1464837659),(339,'DIV',0,69,1,1465200467,1465200467),(340,'他来了，请闭眼',0,109,1,1465353857,1465353857),(341,'我是杜拉拉',0,109,1,1465353864,1465353864),(342,'23',0,109,1,1465702386,1465702386),(343,'未归档视频',0,125,1,1465811078,1465811078),(344,'测试视频',0,121,1,1465993826,1465993826),(345,'未归档视频',0,126,1,1466417788,1466417788),(346,'未归档视频',0,127,1,1466586924,1466586924),(347,'未归档视频',0,128,1,1467251866,1467251866),(348,'未归档视频',0,129,1,1467603515,1467603515),(349,'好先生',0,129,1,1467624891,1467624891),(350,'我是杜拉拉',0,129,1,1467624903,1467624903),(351,'我是杜拉拉',0,40,1,1467943735,1467943735),(352,'car brand',0,49,1,1468222304,1468222304),(353,'好先生',0,40,1,1468390125,1468390125),(354,'好先生_1',0,40,2,1468390125,1468390136),(355,'未归档视频',0,130,1,1468927593,1468927593);
/*!40000 ALTER TABLE `video_folder` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `video_hash`
--

DROP TABLE IF EXISTS `video_hash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `video_hash` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `bucket` varchar(255) NOT NULL COMMENT '存在七牛的空间名',
  `bucket_domin` varchar(255) NOT NULL COMMENT '存在七牛空间的domin',
  `hash` varchar(255) NOT NULL COMMENT 'video 的hash值，存在七牛的文件key，',
  `upload_time` int(11) NOT NULL COMMENT '视频上传时间戳，同时也是提交切图时间戳',
  `video_url` varchar(255) DEFAULT NULL COMMENT '视频url',
  `snap_url` varchar(255) DEFAULT NULL COMMENT '视频截图的地址',
  `video_length` int(11) DEFAULT NULL COMMENT '视频长度，单位s',
  `codec` varchar(255) DEFAULT NULL COMMENT '视频编码流',
  `height` int(11) DEFAULT NULL COMMENT '视频分辨率：高度',
  `width` int(11) DEFAULT NULL COMMENT '视频分辨率：宽度',
  `err_msg` varchar(1023) DEFAULT NULL COMMENT '错误信息',
  PRIMARY KEY (`id`,`hash`),
  UNIQUE KEY `video_url` (`video_url`)
) ENGINE=InnoDB AUTO_INCREMENT=1295 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `video_hash`
--

LOCK TABLES `video_hash` WRITE;
/*!40000 ALTER TABLE `video_hash` DISABLE KEYS */;
/*!40000 ALTER TABLE `video_hash` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videos_info`
--

DROP TABLE IF EXISTS `videos_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videos_info` (
  `vid` int(11) NOT NULL AUTO_INCREMENT COMMENT '视频自增id',
  `video_name` varchar(255) NOT NULL COMMENT '视频中文名/用户输入的名字',
  `url` varchar(255) NOT NULL COMMENT '视频链接',
  `upload_time` int(11) NOT NULL COMMENT '用户上传视频时间，',
  `member_id` int(11) NOT NULL COMMENT '上传者id',
  `last_update_time` int(11) DEFAULT NULL,
  `is_delete` int(11) DEFAULT NULL,
  `job_status_id` int(11) DEFAULT NULL COMMENT '该视频最后一次分析的job_status表id',
  `finish_analysis` int(11) DEFAULT NULL COMMENT '最后一次分析job是否已经完成，0:未完成，1:已完成，2:失败，目前还无法分开，涉及到前端显示，联表操作略麻烦',
  `folder_id` int(11) NOT NULL DEFAULT '0' COMMENT '属于哪个folder， folder表主键，默认0表示根目录，根目录在连表时需要剔除',
  PRIMARY KEY (`vid`)
) ENGINE=InnoDB AUTO_INCREMENT=3395 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videos_info`
--

LOCK TABLES `videos_info` WRITE;
/*!40000 ALTER TABLE `videos_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `videos_info` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-08-08 15:53:23
