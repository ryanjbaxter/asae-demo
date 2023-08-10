package com.example.chaos.monkey.shopping.bestseller.toys;

import com.example.chaos.monkey.shopping.domain.Product;
import com.example.chaos.monkey.shopping.domain.ProductBuilder;
import com.example.chaos.monkey.shopping.domain.ProductCategory;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;

/**
 * @author Benjamin Wilms
 */
@RestController
public class BestsellerToysRestController {
    private final ProductRepository repo;

    private String appid = UUID.randomUUID().toString();

    public BestsellerToysRestController(ProductRepository repo) {
        this.repo = repo;
    }

    @PostConstruct
    public void loadData() {
        repo.deleteAll();

        AtomicLong aLong = new AtomicLong(1);

        ProductBuilder productBuilder = new ProductBuilder();

        Product product1 = productBuilder
                .setCategory(ProductCategory.TOYS)
                .setId(aLong.getAndIncrement())
                //.setName("LEGO Star Wars Yodas Hut")
                .setName("LEGO Star Trek USS Enterprise")
                .createProduct();

        Product product2 = productBuilder
                .setCategory(ProductCategory.TOYS)
                .setId(aLong.getAndIncrement())
                //.setName("LEGO Star Wars Millennium Falcon")
                .setName("LEGO Star Trek Romulan Bird of Prey")
                .createProduct();

        Product product3 = productBuilder
                .setCategory(ProductCategory.TOYS)
                .setId(aLong.getAndIncrement())
                //.setName("LEGO Star Wars Imperial Tie Fighter")
                .setName("LEGO Star Trek Klingon Battle Cruiser")
                .createProduct();

        repo.saveAll(List.of(product1, product2, product3));
    }

    @GetMapping("/toys/bestseller")
    public Iterable<Product> getBestsellerProducts(HttpServletResponse response) {
        response.addHeader("appid", appid);
        return repo.findAll();
    }
}
