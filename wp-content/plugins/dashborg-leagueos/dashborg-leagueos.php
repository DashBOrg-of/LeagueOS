<?php
/**
 * Plugin Name: DashBOrg LeagueOS
 * Description: WordPress catalog and human/agent bridge for shared project operations.
 * Version: 0.1.0
 */

defined( 'ABSPATH' ) || exit;

function dashborg_leagueos_nouns() {
	return array(
		'agent', 'harness', 'workspace', 'repository', 'worktree', 'branch',
		'environment', 'deployment', 'issue', 'pull_request', 'evidence', 'event',
	);
}

function dashborg_leagueos_register_nouns() {
	foreach ( dashborg_leagueos_nouns() as $noun ) {
		register_post_type( 'dashborg_' . $noun, array(
			'label'        => ucwords( str_replace( '_', ' ', $noun ) ),
			'public'       => false,
			'show_ui'      => true,
			'show_in_rest' => true,
			'supports'     => array( 'title', 'editor', 'custom-fields' ),
		) );
	}
}
add_action( 'init', 'dashborg_leagueos_register_nouns' );

function dashborg_leagueos_health( WP_REST_Request $request ) {
	return rest_ensure_response( array(
		'service' => 'dashborg-leagueos',
		'status'  => 'ok',
		'authority' => 'wordpress',
		'nouns'   => dashborg_leagueos_nouns(),
		'time'    => current_time( 'mysql', true ),
	) );
}

function dashborg_leagueos_catalog( WP_REST_Request $request ) {
	$catalog = array();
	foreach ( dashborg_leagueos_nouns() as $noun ) {
		$catalog[ $noun ] = array(
			'post_type' => 'dashborg_' . $noun,
			'endpoint'  => rest_url( 'wp/v2/dashborg_' . $noun ),
		);
	}
	return rest_ensure_response( array( 'authority' => 'wordpress', 'catalog' => $catalog ) );
}

function dashborg_leagueos_register_routes() {
	register_rest_route( 'dashborg/v1', '/health', array(
		'methods' => WP_REST_Server::READABLE,
		'callback' => 'dashborg_leagueos_health',
		'permission_callback' => '__return_true',
	) );
	register_rest_route( 'dashborg/v1', '/catalog', array(
		'methods' => WP_REST_Server::READABLE,
		'callback' => 'dashborg_leagueos_catalog',
		'permission_callback' => '__return_true',
	) );
}
add_action( 'rest_api_init', 'dashborg_leagueos_register_routes' );
