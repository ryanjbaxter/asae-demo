package org.example.chaos.monkey.shopping.allitems;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.web.reactive.function.client.WebClient;

@SpringBootApplication
public class AllIItemsApplication {

	public static void main(String[] args) {
		SpringApplication.run(AllIItemsApplication.class, args);
	}

	@Bean
	@LoadBalanced
	public WebClient.Builder webClient() {
		return WebClient.builder();
	}
}
