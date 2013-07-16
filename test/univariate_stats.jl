# Comparison of empirical stats with expected stats

using Distributions
using Base.Test

const n_samples = 5_000_001

macro check_deviation(title, v, vhat)    
    quote
        abs_dev = abs($v - $vhat)
        if $v != 0.
            rel_dev = abs_dev / abs($v)
            @printf "    %-8s: expect = %10.3e emp = %10.3e  |  abs.dev = %.2e rel.dev = %.2e\n" $title $v $vhat abs_dev rel_dev
        else
            @printf "    %-8s: expect = %10.3e emp = %10.3e  |  abs.dev = %.2e rel.dev = n/a\n" $title $v $vhat abs_dev
        end
    end
end

for d in [Arcsine(),
          Bernoulli(0.1),
          Bernoulli(0.5),
          Bernoulli(0.9),
          Beta(2.0, 2.0),
          Beta(3.0, 4.0),
          Beta(17.0, 13.0),
          # BetaPrime(3.0, 3.0),
          # BetaPrime(3.0, 5.0),
          # BetaPrime(5.0, 3.0),
          Binomial(1, 0.5),
          Binomial(100, 0.1),
          Binomial(100, 0.9),
          Categorical([0.1, 0.9]),
          Categorical([0.5, 0.5]),
          Categorical([0.9, 0.1]),
          Cauchy(0.0, 1.0),
          Cauchy(10.0, 1.0),
          Cauchy(0.0, 10.0),
          Chi(12),
          Chisq(8),
          Chisq(12.0),
          Chisq(20.0),
          # Cosine(),
          DiscreteUniform(0, 3),
          DiscreteUniform(2.0, 5.0),
          # Empirical(),
          Erlang(1),
          Erlang(17.0),
          Exponential(1.0),
          Exponential(5.1),
          FDist(9, 9),
          FDist(9, 21),
          FDist(21, 9),
          Gamma(3.0, 2.0),
          Gamma(2.0, 3.0),
          Gamma(3.0, 3.0),
          Geometric(0.1),
          Geometric(0.5),
          Geometric(0.9),
          Gumbel(3.0, 5.0),
          Gumbel(5, 3),
          # HyperGeometric(1.0, 1.0, 1.0),
          # HyperGeometric(2.0, 2.0, 2.0),
          # HyperGeometric(3.0, 2.0, 2.0),
          # HyperGeometric(2.0, 3.0, 2.0),
          # HyperGeometric(2.0, 2.0, 3.0),
          # InvertedGamma(),
          Laplace(0.0, 1.0),
          Laplace(10.0, 1.0),
          Laplace(0.0, 10.0),
          Levy(0.0, 1.0),
          Levy(2.0, 8.0),
          Levy(3.0, 3.0),
          Logistic(0.0, 1.0),
          Logistic(10.0, 1.0),
          Logistic(0.0, 10.0),
          LogNormal(0.0, 1.0),
          LogNormal(10.0, 1.0),
          LogNormal(0.0, 10.0),
          # NegativeBinomial(),
          # NegativeBinomial(5, 0.6),
          # NoncentralBeta(),
          # NoncentralChisq(),
          # NoncentralFDist(),
          # NoncentralTDist(),
          Normal(0.0, 1.0),
          Normal(-1.0, 10.0),
          Normal(1.0, 10.0),
          # Pareto(),
          Poisson(2.0),
          Poisson(10.0),
          Poisson(51.0),
          Rayleigh(1.0),
          Rayleigh(5.0),
          Rayleigh(10.0),
          # Skellam(10.0, 2.0), # Entropy wrong
          # TDist(1), # Entropy wrong
          # TDist(28), # Entropy wrong
          Triangular(3.0, 1.0),
          Triangular(3.0, 2.0),
          Triangular(10.0, 10.0),
          # TruncatedNormal(Normal(0, 1), -3, 3),
          # TruncatedNormal(Normal(-100, 1), 0, 1),
          # TruncatedNormal(Normal(27, 3), 0, Inf),
          Uniform(0.0, 1.0),
          Uniform(3.0, 17.0),
          Uniform(3.0, 3.1),
          Weibull(2.3),
          Weibull(23.0),
          Weibull(230.0)]

    x = rand(d, n_samples)

    mu, mu_hat = mean(d), mean(x)
    ent, ent_hat = entropy(d), -mean(logpdf(d, x))
    ent2, ent_hat2 = entropy(d), -mean(log(pdf(d, x)))
    m, m_hat = median(d), median(x)
    sigma, sigma_hat = var(d), var(x)
    sk, sk_hat = skewness(d), skewness(x)
    k, k_hat = kurtosis(d), kurtosis(x)

    println(d)

    # empirical mean should be close to theoretical value
    if isfinite(mu)
        @check_deviation "mean" mu mu_hat
    end

    # empirical variance should be close to theoretical value
    if isfinite(mu) && isfinite(sigma)       
        @check_deviation "variance" sigma sigma_hat
    end

    # empirical skewness should be close to theoretical value
    if isfinite(mu) && isfinite(sk) 
        @check_deviation "skewness" sk sk_hat
    end

    # empirical kurtosis should be close to theoretical value
    # Empirical kurtosis is very unstable for FDist
    if isfinite(mu) && isfinite(k)
        @check_deviation "kurtosis" k k_hat
    end

    # By the Asymptotic Equipartition Property,
    # empirical mean negative log PDF should be close to theoretical value
    if isfinite(ent) && !isa(d, Arcsine)
        @check_deviation "entropy" ent ent_hat
    end

    if insupport(d, m_hat) && isa(d, ContinuousDistribution) && !isa(d, FDist)
        @check_deviation "median" m m_hat
    end

    println()
end

