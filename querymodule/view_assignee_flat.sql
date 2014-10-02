select `a`.`id` AS `assignee_id`,`a`.`type` AS `type`,`a`.`name_first` AS `name_first`,`a`.`name_last` AS `name_last`,`a`.`organization` AS `organization`,`a`.`residence` AS `residence`,`a`.`nationality` AS `nationality`,`l`.`id` AS `location_id`,`l`.`city` AS `city`,`l`.`state` AS `state`,`l`.`country` AS `country`,`l`.`latitude` AS `latitude`,`l`.`longitude` AS `longitude` from ((`assignee` `a` left join `location_assignee` `la` on((`a`.`id` = `la`.`assignee_id`))) left join `location` `l` on((`la`.`location_id` = `l`.`id`)))