jms.queue.name = books-queue
[#if dependencyIsPresent.apply("spring-boot-starter-activemq")]
spring.artemis.mode=embedded
spring.artemis.host=localhost
spring.artemis.port=61616
spring.artemis.user=test
spring.artemis.password=test
spring.artemis.embedded.enabled=true
spring.artemis.embedded.queue=${jms.queue.name}
[/#if]
