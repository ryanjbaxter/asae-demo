package com.example.chaos.monkey.shopping.bestseller.toys;

import de.codecentric.spring.boot.chaos.monkey.configuration.ChaosMonkeyProperties;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.context.environment.EnvironmentChangeEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

@SpringBootApplication
@EnableDiscoveryClient
public class BestsellerToysApplication {

	public static void main(String[] args) {
		SpringApplication.run(BestsellerToysApplication.class, args);
	}

	@Configuration
	public static class ChaosMonkeyRefreshListener implements ApplicationListener<EnvironmentChangeEvent> {
		ChaosMonkeyProperties chaosMonkeyProperties;

		Environment environment;

		public ChaosMonkeyRefreshListener(ChaosMonkeyProperties chaosMonkeyProperties, Environment environment) {
			this.chaosMonkeyProperties = chaosMonkeyProperties;
			this.environment = environment;
		}

		@Override
		public void onApplicationEvent(EnvironmentChangeEvent event) {

			if(event.getKeys().contains("chaos.monkey.enabled")) {
				chaosMonkeyProperties.setEnabled(environment.getProperty("chaos.monkey.enabled", Boolean.class));
			}
		}
	}
}
 