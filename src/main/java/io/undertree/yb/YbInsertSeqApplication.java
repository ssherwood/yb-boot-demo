package io.undertree.yb;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableTransactionManagement
@EnableCaching
@EnableScheduling
public class YbInsertSeqApplication {

    public static void main(String[] args) {

        // enabled no-nestloop hints on driver
        System.setProperty("ybdb.pgdbmetadata.nestedloop.disable", "true");

        // configure parallel connection creation at startup
        //System.setProperty("com.zaxxer.hikari.blockUntilFilled", "true");

        SpringApplication.run(YbInsertSeqApplication.class, args);
    }

}