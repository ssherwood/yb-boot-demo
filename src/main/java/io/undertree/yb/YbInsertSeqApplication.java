package io.undertree.yb;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableTransactionManagement
public class YbInsertSeqApplication {

    public static void main(String[] args) {

        // enabled no-nestloop hints on driver
        System.setProperty("ybdb.pgdbmetadata.nestedloop.disable", "true");

        // configure parallel connection creation at startup
        //System.setProperty("com.zaxxer.hikari.blockUntilFilled", "true");

        SpringApplication.run(YbInsertSeqApplication.class, args);
    }

}