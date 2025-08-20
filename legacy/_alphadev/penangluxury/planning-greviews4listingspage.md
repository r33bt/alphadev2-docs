# Google Reviews Integration - Product Requirements & Solution Document

## 1. Overview
Implement a scalable, performant solution to display Google Reviews for each listing in the directory, using the Google Places API and WordPress.

## 2. Requirements

### 2.1 Functional Requirements
1. **Review Display**
   - Show average rating
   - Display total number of reviews
   - List individual reviews with:
     - Author name and photo
     - Rating (stars)
     - Review text
     - Review date
     - Review photos (if available)

2. **Dynamic Integration**
   - Pull reviews based on Google Place ID stored in ACF
   - Update reviews automatically
   - Handle missing or invalid Place IDs gracefully

3. **Performance**
   - Implement caching to minimize API calls
   - Lazy load reviews
   - Handle API rate limits
   - Optimize for mobile

4. **User Experience**
   - Responsive design
   - Loading states
   - Error handling
   - Accessibility compliance

### 2.2 Technical Requirements
1. **API Integration**
   - Google Places API integration
   - Secure API key management
   - Rate limiting implementation

2. **Caching System**
   - Cache reviews for 12 hours
   - Cache invalidation on demand
   - Fallback to cached data on API failure

3. **Security**
   - Secure API key storage
   - Input validation
   - Output sanitization
   - Nonce verification

## 3. Proposed Solution

### 3.1 Architecture

```
wp-content/
  themes/
    your-theme/
      includes/
        class-google-reviews.php      // Main class
        class-google-reviews-cache.php // Caching handler
        class-google-reviews-api.php   // API handler
      assets/
        css/
          google-reviews.css
        js/
          google-reviews.js
```

### 3.2 Implementation Details

#### 3.2.1 Main Class (`class-google-reviews.php`)

```php
<?php
class Google_Reviews {
    private $api;
    private $cache;
    private $api_key;
    
    public function __construct() {
        $this->api_key = get_option('google_places_api_key');
        $this->api = new Google_Reviews_API($this->api_key);
        $this->cache = new Google_Reviews_Cache();
    }
    
    public function get_reviews($place_id) {
        // Check cache first
        $cached_data = $this->cache->get($place_id);
        if ($cached_data !== false) {
            return $cached_data;
        }
        
        // Fetch from API
        $reviews_data = $this->api->fetch_reviews($place_id);
        if ($reviews_data) {
            $this->cache->set($place_id, $reviews_data);
        }
        
        return $reviews_data;
    }
    
    public function render_reviews($place_id) {
        $reviews_data = $this->get_reviews($place_id);
        if (!$reviews_data) {
            return $this->render_error();
        }
        
        ob_start();
        include get_template_directory() . '/includes/templates/reviews-template.php';
        return ob_get_clean();
    }
}
```

#### 3.2.2 API Handler (`class-google-reviews-api.php`)

```php
<?php
class Google_Reviews_API {
    private $api_key;
    private $base_url = 'https://maps.googleapis.com/maps/api/place/details/json';
    
    public function __construct($api_key) {
        $this->api_key = $api_key;
    }
    
    public function fetch_reviews($place_id) {
        $args = array(
            'placeid' => $place_id,
            'key' => $this->api_key,
            'fields' => 'reviews,rating,user_ratings_total,photos'
        );
        
        $response = wp_remote_get(add_query_arg($args, $this->base_url));
        
        if (is_wp_error($response)) {
            return false;
        }
        
        $body = wp_remote_retrieve_body($response);
        $data = json_decode($body, true);
        
        if (!empty($data['result'])) {
            return $this->format_reviews_data($data['result']);
        }
        
        return false;
    }
    
    private function format_reviews_data($data) {
        return array(
            'rating' => $data['rating'] ?? 0,
            'total_ratings' => $data['user_ratings_total'] ?? 0,
            'reviews' => array_map(function($review) {
                return array(
                    'author_name' => $review['author_name'],
                    'author_photo' => $review['profile_photo_url'],
                    'rating' => $review['rating'],
                    'text' => $review['text'],
                    'time' => $review['relative_time_description'],
                    'photos' => $review['photos'] ?? array()
                );
            }, $data['reviews'] ?? array())
        );
    }
}
```

#### 3.2.3 Cache Handler (`class-google-reviews-cache.php`)

```php
<?php
class Google_Reviews_Cache {
    private $cache_time = 12 * HOUR_IN_SECONDS;
    
    public function get($place_id) {
        $transient_key = 'google_reviews_' . md5($place_id);
        return get_transient($transient_key);
    }
    
    public function set($place_id, $data) {
        $transient_key = 'google_reviews_' . md5($place_id);
        set_transient($transient_key, $data, $this->cache_time);
    }
    
    public function clear($place_id) {
        $transient_key = 'google_reviews_' . md5($place_id);
        delete_transient($transient_key);
    }
}
```

#### 3.2.4 Template (`reviews-template.php`)

```php
<?php
/**
 * Template for displaying Google Reviews
 */
?>
<div class="google-reviews" data-place-id="<?php echo esc_attr($place_id); ?>">
    <div class="reviews-summary">
        <div class="average-rating">
            <div class="stars">
                <?php for ($i = 1; $i <= 5; $i++): ?>
                    <span class="star <?php echo $i <= $reviews_data['rating'] ? 'filled' : ''; ?>">★</span>
                <?php endfor; ?>
            </div>
            <div class="rating-number"><?php echo number_format($reviews_data['rating'], 1); ?></div>
            <div class="total-ratings">(<?php echo $reviews_data['total_ratings']; ?> reviews)</div>
        </div>
    </div>
    
    <div class="reviews-list">
        <?php foreach ($reviews_data['reviews'] as $review): ?>
            <div class="review-item">
                <div class="review-header">
                    <img src="<?php echo esc_url($review['author_photo']); ?>" 
                         alt="<?php echo esc_attr($review['author_name']); ?>" 
                         class="author-photo">
                    <div class="author-info">
                        <div class="author-name"><?php echo esc_html($review['author_name']); ?></div>
                        <div class="review-time"><?php echo esc_html($review['time']); ?></div>
                    </div>
                    <div class="review-rating">
                        <?php for ($i = 1; $i <= 5; $i++): ?>
                            <span class="star <?php echo $i <= $review['rating'] ? 'filled' : ''; ?>">★</span>
                        <?php endfor; ?>
                    </div>
                </div>
                <div class="review-content">
                    <p><?php echo esc_html($review['text']); ?></p>
                </div>
                <?php if (!empty($review['photos'])): ?>
                    <div class="review-photos">
                        <?php foreach ($review['photos'] as $photo): ?>
                            <img src="<?php echo esc_url($photo); ?>" alt="Review photo" class="review-photo">
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>
    </div>
</div>
```

#### 3.2.5 CSS (`google-reviews.css`)

```css
.google-reviews {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
}

.reviews-summary {
    margin-bottom: 2rem;
}

.average-rating {
    display: flex;
    align-items: center;
    gap: 1rem;
}

.stars {
    display: flex;
    gap: 0.25rem;
}

.star {
    color: #ccc;
    font-size: 1.5rem;
}

.star.filled {
    color: #ffb400;
}

.rating-number {
    font-size: 1.5rem;
    font-weight: bold;
}

.total-ratings {
    color: #666;
}

.review-item {
    border: 1px solid #eee;
    border-radius: 8px;
    padding: 1.5rem;
    margin-bottom: 1.5rem;
}

.review-header {
    display: flex;
    align-items: center;
    gap: 1rem;
    margin-bottom: 1rem;
}

.author-photo {
    width: 48px;
    height: 48px;
    border-radius: 50%;
}

.author-info {
    flex: 1;
}

.author-name {
    font-weight: bold;
}

.review-time {
    color: #666;
    font-size: 0.9rem;
}

.review-content {
    line-height: 1.6;
    margin-bottom: 1rem;
}

.review-photos {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
    gap: 0.5rem;
    margin-top: 1rem;
}

.review-photo {
    width: 100%;
    height: 100px;
    object-fit: cover;
    border-radius: 4px;
}

@media (max-width: 768px) {
    .average-rating {
        flex-direction: column;
        align-items: flex-start;
    }
    
    .review-header {
        flex-direction: column;
        align-items: flex-start;
    }
}
```

#### 3.2.6 JavaScript (`google-reviews.js`)

```javascript
document.addEventListener('DOMContentLoaded', function() {
    // Lazy load reviews
    const reviewContainers = document.querySelectorAll('.google-reviews');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const container = entry.target;
                loadReviews(container);
                observer.unobserve(container);
            }
        });
    });
    
    reviewContainers.forEach(container => {
        observer.observe(container);
    });
});

function loadReviews(container) {
    const placeId = container.dataset.placeId;
    
    // Show loading state
    container.innerHTML = '<div class="loading">Loading reviews...</div>';
    
    // Fetch reviews via AJAX
    fetch(`/wp-json/google-reviews/v1/reviews/${placeId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                container.innerHTML = data.html;
            } else {
                container.innerHTML = '<div class="error">Failed to load reviews</div>';
            }
        })
        .catch(error => {
            container.innerHTML = '<div class="error">Failed to load reviews</div>';
        });
}
```

### 3.3 Integration Steps

1. **Setup**
   - Create required directories and files
   - Add Google Places API key to WordPress options
   - Create ACF field for Place ID

2. **Implementation**
   - Add classes to theme's functions.php
   - Enqueue CSS and JS files
   - Add shortcode support
   - Test API integration

3. **Testing**
   - Test with valid and invalid Place IDs
   - Verify caching works
   - Check mobile responsiveness
   - Test error handling

4. **Deployment**
   - Add to version control
   - Deploy to staging
   - Test in production
   - Monitor API usage

## 4. Maintenance Plan

1. **Regular Updates**
   - Monitor API usage
   - Update cache as needed
   - Check for API changes

2. **Performance Monitoring**
   - Track load times
   - Monitor API response times
   - Check cache hit rates

3. **Error Handling**
   - Log API errors
   - Monitor failed requests
   - Update error handling as needed

## 5. Security Considerations

1. **API Key Security**
   - Store in WordPress options
   - Restrict API key usage
   - Monitor usage patterns

2. **Data Security**
   - Validate all inputs
   - Sanitize all outputs
   - Use nonces for AJAX requests

3. **Rate Limiting**
   - Implement request throttling
   - Monitor for abuse
   - Handle rate limit errors