package [=package];

import com.mongodb.ConnectionString;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.beans.factory.annotation.Value;

@Configuration
public class MongoDBConfiguration {
    @Value("${mongodb.hosts}")
    private String hosts;

    @Bean("camelMongoDBClient")
    public MongoClient createMongoDBClient(){
        return MongoClients.create(new ConnectionString(hosts));
    }
}
