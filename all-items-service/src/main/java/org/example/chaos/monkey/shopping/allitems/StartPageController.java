package org.example.chaos.monkey.shopping.allitems;

import java.util.Collections;
import java.util.function.Function;

import com.example.chaos.monkey.shopping.domain.Product;
import org.example.chaos.monkey.shopping.allitems.domain.ProductResponse;
import org.example.chaos.monkey.shopping.allitems.domain.ResponseType;
import org.example.chaos.monkey.shopping.allitems.domain.Startpage;
import reactor.core.publisher.Mono;

import org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreaker;
import org.springframework.cloud.client.circuitbreaker.ReactiveCircuitBreakerFactory;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.ClientResponse;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * @author Ryan Baxter
 */
@RestController
public class StartPageController {

	private static final ParameterizedTypeReference<Product> PRODUCT_PARAMETERIZED_TYPE_REFERENCE =
			new ParameterizedTypeReference<>() {};

	private static final Function<Throwable, Mono<ProductResponse>> FALLBACK = t -> Mono.just(new ProductResponse(ResponseType.FALLBACK, Collections.emptyList()));

	private static final Function<ClientResponse, ? extends Mono<ProductResponse>> RESPONSE_PROCESSOR = clientResponse -> clientResponse.bodyToFlux(PRODUCT_PARAMETERIZED_TYPE_REFERENCE).collectList().flatMap(products -> Mono.just(new ProductResponse(ResponseType.REMOTE_SERVICE, products)));

	private WebClient.Builder builder;
	private ProductResponse errorResponse;

	private final ReactiveCircuitBreaker toysCb;

	private final ReactiveCircuitBreaker fashionCb;

	private final ReactiveCircuitBreaker hotdealsCb;

	public StartPageController(WebClient.Builder webClientBuilder, ReactiveCircuitBreakerFactory cbFactory) {
		this.builder = webClientBuilder;
		this.toysCb = cbFactory.create("toys");
		this.fashionCb = cbFactory.create("fashion");
		this.hotdealsCb = cbFactory.create("hotdeals");
		this.errorResponse = new ProductResponse();
		errorResponse.setResponseType(ResponseType.ERROR);
		errorResponse.setProducts(Collections.emptyList());
	}


	@GetMapping("/startpage")
	public Mono<Startpage> getStartpage() {
		long start = System.currentTimeMillis();
		Mono<ProductResponse> hotdeals = builder.build().get().uri("http://hot-deals/hotdeals").exchangeToMono(RESPONSE_PROCESSOR)
				.transform(it -> hotdealsCb.run(it, FALLBACK));
		Mono<ProductResponse> fashionBestSellers = builder.build().get().uri("http://fashion-bestseller/fashion/bestseller").exchangeToMono(RESPONSE_PROCESSOR)
				.transform(it -> fashionCb.run(it, FALLBACK));
		Mono<ProductResponse> toysBestSellers = builder.build().get().uri("http://toys-bestseller/toys/bestseller")
				.exchangeToMono(RESPONSE_PROCESSOR).transform(it -> toysCb.run(it, FALLBACK));

		Mono<Startpage> page = Mono.zip(hotdeals, fashionBestSellers, toysBestSellers).flatMap(t -> {
			Startpage p = new Startpage();
			ProductResponse deals = t.getT1();
			ProductResponse fashion = t.getT2();
			ProductResponse toys = t.getT3();
			p.setFashionResponse(fashion);
			p.setHotDealsResponse(deals);
			p.setToysResponse(toys);
			p.setStatusFashion(fashion.getResponseType().name());
			p.setStatusHotDeals(deals.getResponseType().name());
			p.setStatusToys(toys.getResponseType().name());
			// Request duration
			p.setDuration(System.currentTimeMillis() - start);
			return Mono.just(p);
		});

		return page;
	}
}
