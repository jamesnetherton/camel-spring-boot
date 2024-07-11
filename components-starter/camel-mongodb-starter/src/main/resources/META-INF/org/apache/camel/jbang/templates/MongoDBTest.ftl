package [=package];

import org.apache.camel.ProducerTemplate;
import org.apache.camel.test.spring.junit5.CamelSpringBootTest;
import org.bson.Document;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.MongoDBContainer;

import static org.junit.jupiter.api.Assertions.assertEquals;

@CamelSpringBootTest
@EnableAutoConfiguration
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class CamelSpringBootSimpleTest {
    @LocalServerPort
    private Integer port;

    @Autowired
    ProducerTemplate template;

    static MongoDBContainer mongodb = new MongoDBContainer(
            "mongo:4.4"
    );

    @BeforeAll
    static void beforeAll() {
        mongodb.start();
    }

    @AfterAll
    static void afterAll() {
        mongodb.stop();
    }

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("mongodb.hosts", mongodb::getConnectionString);
    }

    @Test
    void testBooksAPI() {
        String bookJson = """
            {
                "_id": "1",
                "title": "Camel In Action"
            }
        """;

        // Insert
        template.sendBody("http://localhost:" + port + "/books", bookJson.trim());

        // Get
        String getResult = template.requestBody("http://localhost:" + port + "/books?id=1", null, String.class);
        Document getResultDocument = Document.parse(getResult);
        assertEquals("1", getResultDocument.get("_id"));
        assertEquals("Camel In Action", getResultDocument.get("title"));

        // Update
        template.sendBody("http://localhost:" + port + "/books?httpMethod=PATCH&id=1&title=Camel In Action 2", null);
        String updateResult = template.requestBody("http://localhost:" + port + "/books?id=1", null, String.class);
        Document updateResultDocument = Document.parse(updateResult);
        assertEquals("1", updateResultDocument.get("_id"));
        assertEquals("Camel In Action 2", updateResultDocument.get("title"));

        // Delete
        template.sendBody("http://localhost:" + port + "/books?httpMethod=DELETE&id=1", null);
    }
}
