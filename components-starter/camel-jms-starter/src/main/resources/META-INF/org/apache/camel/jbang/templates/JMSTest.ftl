package [=package];

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.test.spring.junit5.CamelSpringBootTest;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import static org.junit.jupiter.api.Assertions.assertEquals;

@CamelSpringBootTest
@EnableAutoConfiguration
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class JMSTest {
    private static final ObjectMapper MAPPER = new ObjectMapper();

    @LocalServerPort
    private Integer port;

    @Autowired
    ProducerTemplate template;

    @Test
    void testBooksAPI() throws Exception {
        String bookJson = """
            {
                "id": "1",
                "title": "Camel In Action"
            }
        """;

        // Generate a JMS message
        template.sendBody("http://localhost:" + port + "/books", bookJson.trim());

        // Wait for the message to be consumed
        Thread.sleep(250);

        // Get results
        String getResult = template.requestBody("http://localhost:" + port + "/books", null, String.class);
        List<Book> books = MAPPER.readValue(getResult, new TypeReference<>(){});
        assertEquals(1, books.size());

        Book book = books.get(0);
        assertEquals(1, book.getId());
        assertEquals("Camel In Action", book.getTitle());
    }
}