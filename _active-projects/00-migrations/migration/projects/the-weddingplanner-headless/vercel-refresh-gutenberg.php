<?php
/**
 * Plugin Name: Vercel Gutenberg Refresh - Wedding Planner
 * Description: Direct Gutenberg integration for Vercel refresh
 * Version: 1.2
 */

if (!defined('ABSPATH')) {
    exit;
}

class VercelGutenbergRefresh {
    private $vercel_url = 'https://the-weddingplanner-headless-kxi0g936u-bruces-projects-39321526.vercel.app';

    public function __construct() {
        add_action('enqueue_block_editor_assets', array($this, 'enqueue_gutenberg_script'));
        add_action('save_post', array($this, 'log_post_save'));
    }

    public function log_post_save($post_id) {
        if (get_post_status($post_id) !== 'publish') {
            return;
        }

        $post = get_post($post_id);
        if (!$post || $post->post_type !== 'post') {
            return;
        }

        error_log("Vercel Gutenberg: Post saved - " . $post->post_title . " (ID: $post_id)");
    }

    public function enqueue_gutenberg_script() {
        $script = "
        (function() {
            const { data, select, subscribe } = wp.data;
            const refreshUrl = '" . esc_js($this->vercel_url) . "/refresh-site.html?auto=1';
            
            let isSaving = false;
            let lastSaveTime = 0;
            
            // Subscribe to editor changes
            subscribe(() => {
                const editor = select('core/editor');
                if (!editor) return;
                
                const currentlySaving = editor.isSavingPost();
                const hasFinishedSaving = isSaving && !currentlySaving;
                const saveTime = Date.now();
                
                // Check if we just finished saving (and it's been more than 2 seconds since last save)
                if (hasFinishedSaving && (saveTime - lastSaveTime) > 2000) {
                    lastSaveTime = saveTime;
                    
                    // Small delay to ensure save is complete
                    setTimeout(() => {
                        const postType = editor.getCurrentPostType();
                        const postStatus = editor.getEditedPostAttribute('status');
                        const postTitle = editor.getEditedPostAttribute('title');
                        
                        if (postType === 'post' && postStatus === 'publish') {
                            console.log('Vercel: Post saved, refreshing site...', postTitle);
                            
                            // Show WordPress notice
                            const notice = wp.data.dispatch('core/notices').createNotice(
                                'success',
                                '✅ Post saved! Refreshing Vercel site automatically...',
                                {
                                    isDismissible: true,
                                    actions: [{
                                        label: 'Open Refresh Page',
                                        url: refreshUrl
                                    }]
                                }
                            );
                            
                            // Open refresh page
                            const refreshWindow = window.open(refreshUrl, 'vercel_refresh', 'width=600,height=400');
                            
                            // Show alert if popup blocked
                            setTimeout(() => {
                                if (!refreshWindow || refreshWindow.closed) {
                                    alert('⚠️ Popup blocked! Click the \"Open Refresh Page\" button above or visit: ' + refreshUrl);
                                } else {
                                    wp.data.dispatch('core/notices').createNotice(
                                        'info',
                                        '🚀 Vercel site refresh initiated! Changes will appear within 30 seconds.',
                                        { isDismissible: true }
                                    );
                                }
                            }, 1000);
                        }
                    }, 500);
                }
                
                isSaving = currentlySaving;
            });
            
            console.log('Vercel Gutenberg Refresh: Initialized for Wedding Planner');
        })();
        ";

        wp_add_inline_script('wp-blocks', $script);
    }
}

new VercelGutenbergRefresh();
?>