-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : Dim 24 jan. 2021 à 20:06
-- Version du serveur :  8.0.21
-- Version de PHP : 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `projetsalonregion`
--

DELIMITER $$
--
-- Fonctions
--
DROP FUNCTION IF EXISTS `get_url_path_of_category`$$
CREATE DEFINER=`calixte`@`%` FUNCTION `get_url_path_of_category` (`categoryId` INT, `localeCode` VARCHAR(255)) RETURNS VARCHAR(255) CHARSET latin1 BEGIN

                DECLARE urlPath VARCHAR(255);

                IF NOT EXISTS (
                    SELECT id
                    FROM categories
                    WHERE
                        id = categoryId
                        AND parent_id IS NULL
                )
                THEN
                    SELECT
                        GROUP_CONCAT(parent_translations.slug SEPARATOR '/') INTO urlPath
                    FROM
                        categories AS node,
                        categories AS parent
                        JOIN category_translations AS parent_translations ON parent.id = parent_translations.category_id
                    WHERE
                        node._lft >= parent._lft
                        AND node._rgt <= parent._rgt
                        AND node.id = categoryId
                        AND node.parent_id IS NOT NULL
                        AND parent.parent_id IS NOT NULL
                        AND parent_translations.locale = localeCode
                    GROUP BY
                        node.id;

                    IF urlPath IS NULL
                    THEN
                        SET urlPath = (SELECT slug FROM category_translations WHERE category_translations.category_id = categoryId);
                    END IF;
                 ELSE
                    SET urlPath = '';
                 END IF;

                 RETURN urlPath;
            END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
CREATE TABLE IF NOT EXISTS `addresses` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `address_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_id` int UNSIGNED DEFAULT NULL COMMENT 'null if guest checkout',
  `cart_id` int UNSIGNED DEFAULT NULL COMMENT 'only for cart_addresses',
  `order_id` int UNSIGNED DEFAULT NULL COMMENT 'only for order_addresses',
  `first_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address1` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address2` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postcode` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vat_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default_address` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'only for customer_addresses',
  `additional` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `addresses_customer_id_foreign` (`customer_id`),
  KEY `addresses_cart_id_foreign` (`cart_id`),
  KEY `addresses_order_id_foreign` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `addresses`
--

INSERT INTO `addresses` (`id`, `address_type`, `customer_id`, `cart_id`, `order_id`, `first_name`, `last_name`, `gender`, `company_name`, `address1`, `address2`, `postcode`, `city`, `state`, `country`, `email`, `phone`, `vat_id`, `default_address`, `additional`, `created_at`, `updated_at`) VALUES
(2, 'customer', 1, NULL, NULL, 'calixte', 'marchand', NULL, '', '121 rue d\'aguesseau', NULL, '91400', 'boulogne billancourt', '12', 'FR', NULL, '04444444', '', 1, NULL, '2020-09-22 22:10:17', '2020-09-22 22:10:17'),
(3, 'cart_billing', 1, 1, NULL, 'calixte', 'marchand', NULL, '', '121 rue d\'aguesseau', NULL, '91400', 'boulogne billancourt', '12', 'FR', 'cmarchand@netysoft.com', '04444444', '', 1, NULL, '2020-10-03 09:58:11', '2020-10-03 09:58:11'),
(4, 'cart_shipping', 1, 1, NULL, 'calixte', 'marchand', NULL, '', '121 rue d\'aguesseau', NULL, '91400', 'boulogne billancourt', '12', 'FR', 'cmarchand@netysoft.com', '04444444', '', 1, NULL, '2020-10-03 09:58:11', '2020-10-03 09:58:11');

-- --------------------------------------------------------

--
-- Structure de la table `admins`
--

DROP TABLE IF EXISTS `admins`;
CREATE TABLE IF NOT EXISTS `admins` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_token` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `role_id` int UNSIGNED NOT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admins_email_unique` (`email`),
  UNIQUE KEY `admins_api_token_unique` (`api_token`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `admins`
--

INSERT INTO `admins` (`id`, `name`, `email`, `password`, `api_token`, `status`, `role_id`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Calixte MARCHAND', 'admin@example.com', '$2y$10$GGHKQqOuZiLzJrGYZzkC7.9qikl3Qk5pvJ9UKo53a3LGO.QU17xvS', 'v40lDxB4i8kZGBGJAptGq4hd3hgptpnDzLaTbM8V3nO8uoZbCI78ggSjpA3dJo8Mf6OLj2swMml21C8d', 1, 1, NULL, '2020-07-13 09:51:42', '2020-09-19 13:02:10');

-- --------------------------------------------------------

--
-- Structure de la table `admin_password_resets`
--

DROP TABLE IF EXISTS `admin_password_resets`;
CREATE TABLE IF NOT EXISTS `admin_password_resets` (
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `admin_password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `attributes`
--

DROP TABLE IF EXISTS `attributes`;
CREATE TABLE IF NOT EXISTS `attributes` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `admin_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `validation` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` int DEFAULT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '0',
  `is_unique` tinyint(1) NOT NULL DEFAULT '0',
  `value_per_locale` tinyint(1) NOT NULL DEFAULT '0',
  `value_per_channel` tinyint(1) NOT NULL DEFAULT '0',
  `is_filterable` tinyint(1) NOT NULL DEFAULT '0',
  `is_configurable` tinyint(1) NOT NULL DEFAULT '0',
  `is_user_defined` tinyint(1) NOT NULL DEFAULT '1',
  `is_visible_on_front` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `swatch_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `use_in_flat` tinyint(1) NOT NULL DEFAULT '1',
  `is_comparable` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `attributes_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `attributes`
--

INSERT INTO `attributes` (`id`, `code`, `admin_name`, `type`, `validation`, `position`, `is_required`, `is_unique`, `value_per_locale`, `value_per_channel`, `is_filterable`, `is_configurable`, `is_user_defined`, `is_visible_on_front`, `created_at`, `updated_at`, `swatch_type`, `use_in_flat`, `is_comparable`) VALUES
(1, 'sku', 'SKU', 'text', NULL, 3, 1, 1, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-07-13 09:51:42', NULL, 1, 0),
(2, 'name', 'Nom', 'text', '', 1, 1, 0, 1, 1, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:13:07', NULL, 1, 1),
(3, 'url_key', 'Clés URL', 'text', '', 3, 1, 1, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:12:53', NULL, 1, 0),
(4, 'tax_category_id', 'Catégorie de taxe', 'select', '', 4, 0, 0, 0, 1, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:12:35', NULL, 1, 0),
(5, 'new', 'Nouveau', 'boolean', '', 5, 0, 0, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:11:38', NULL, 1, 0),
(6, 'featured', 'Populaire', 'boolean', '', 6, 0, 0, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:11:23', NULL, 1, 0),
(7, 'visible_individually', 'Visible Individuellement', 'boolean', '', 7, 1, 0, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:10:06', NULL, 1, 0),
(8, 'status', 'Statut', 'boolean', '', 8, 1, 0, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:09:50', NULL, 1, 0),
(9, 'short_description', 'Description courte', 'textarea', '', 9, 1, 0, 1, 1, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:09:22', NULL, 1, 0),
(10, 'description', 'Description', 'textarea', NULL, 10, 1, 0, 1, 1, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-07-13 09:51:42', NULL, 1, 1),
(11, 'price', 'Prix', 'price', 'decimal', 11, 1, 0, 0, 0, 1, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:08:56', NULL, 1, 1),
(12, 'cost', 'Coût', 'price', 'decimal', 12, 0, 0, 0, 1, 0, 0, 1, 0, '2020-07-13 09:51:42', '2020-09-23 07:08:32', NULL, 1, 0),
(13, 'special_price', 'Prix spécial', 'price', 'decimal', 13, 0, 0, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:08:00', NULL, 1, 0),
(14, 'special_price_from', 'Prix spécial jusqu\'à', 'date', '', 14, 0, 0, 0, 1, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:07:31', NULL, 1, 0),
(15, 'special_price_to', 'Prix spécial à partir de', 'date', '', 15, 0, 0, 0, 1, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:06:54', NULL, 1, 0),
(16, 'meta_title', 'Meta Title', 'textarea', NULL, 16, 0, 0, 1, 1, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-07-13 09:51:42', NULL, 1, 0),
(17, 'meta_keywords', 'Meta Keywords', 'textarea', NULL, 17, 0, 0, 1, 1, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-07-13 09:51:42', NULL, 1, 0),
(18, 'meta_description', 'Meta Description', 'textarea', NULL, 18, 0, 0, 1, 1, 0, 0, 1, 0, '2020-07-13 09:51:42', '2020-07-13 09:51:42', NULL, 1, 0),
(22, 'weight', 'Poid', 'text', 'decimal', 22, 1, 0, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:04:45', NULL, 1, 0),
(23, 'color', 'Couleur', 'select', '', 23, 0, 0, 0, 0, 1, 1, 1, 0, '2020-07-13 09:51:42', '2020-09-23 07:04:28', NULL, 1, 0),
(25, 'brand', 'Marque/Domaine', 'select', '', 25, 0, 0, 0, 0, 1, 0, 0, 1, '2020-07-13 09:51:42', '2020-09-26 12:31:30', NULL, 1, 0),
(26, 'guest_checkout', 'Vérification des invités', 'boolean', '', 8, 1, 0, 0, 0, 0, 0, 0, 0, '2020-07-13 09:51:42', '2020-09-23 07:16:25', NULL, 1, 0),
(27, 'region', 'Région Vin', 'select', '', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2020-09-23 15:59:15', '2020-09-24 07:23:02', 'dropdown', 1, 1),
(29, 'Libelle_commercial', 'Libéllé commercial', 'text', '', 2, 1, 1, 0, 0, 0, 0, 1, 1, '2020-09-27 09:34:38', '2020-09-27 09:34:38', NULL, 0, 0),
(30, 'Origine', 'Origine', 'select', '', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 09:41:01', '2020-09-27 09:41:01', 'dropdown', 1, 1),
(31, 'Pays', 'Pays d\'origine', 'select', '', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 09:48:38', '2020-09-27 09:48:38', NULL, 1, 0),
(32, 'Millesime', 'Millésime', 'select', '', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 09:51:37', '2020-09-27 09:51:37', 'dropdown', 1, 1),
(33, 'Contenance', 'Contenance', 'select', '', NULL, 1, 0, 0, 0, 1, 1, 1, 1, '2020-09-27 09:54:33', '2020-09-27 09:54:33', 'dropdown', 1, 0),
(34, 'EAN', 'EAN', 'text', 'numeric', NULL, 0, 1, 0, 0, 0, 0, 1, 1, '2020-09-27 09:58:07', '2020-09-27 09:58:07', NULL, 1, 0),
(35, 'Conditionnement', 'Conditionnement', 'select', '', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 10:00:03', '2020-09-27 10:00:03', 'dropdown', 1, 1),
(36, 'PCB', 'PCB', 'text', 'numeric', NULL, 1, 0, 0, 0, 0, 0, 1, 0, '2020-09-27 10:01:15', '2020-09-27 10:01:15', NULL, 1, 1),
(37, 'Mise_en_bouteille', 'Mise en bouteille', 'select', '', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 10:05:25', '2020-09-27 10:05:25', 'dropdown', 1, 1),
(40, 'Recompenses', 'Récompenses', 'multiselect', '', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 10:11:28', '2020-09-27 10:11:28', NULL, 1, 1),
(41, 'Top_affaire', 'Top affaire', 'multiselect', '', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 10:14:14', '2020-09-27 10:14:14', NULL, 1, 0),
(42, 'Gouts_majeur', 'Gouts majeur', 'multiselect', '', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 10:15:30', '2020-09-27 10:15:30', NULL, 1, 1),
(43, 'Gouts', 'Gouts', 'textarea', '', NULL, 0, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:16:46', '2020-09-27 10:16:46', NULL, 1, 0),
(44, 'Conservation', 'Conservation', 'select', '', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 10:18:33', '2020-09-27 10:18:33', 'dropdown', 1, 1),
(45, 'Degre_alcoole', 'Degré d\'alcool', 'text', '', NULL, 1, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:20:22', '2020-09-27 10:20:22', NULL, 1, 1),
(46, 'Accord_recommandes', 'Accords recommandés', 'textarea', '', NULL, 0, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:23:21', '2020-09-27 10:23:21', NULL, 1, 1),
(47, 'Bouchon', 'Bouchon', 'select', '', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 10:25:12', '2020-09-27 10:25:12', 'dropdown', 1, 1),
(48, 'Oeil', 'A œil', 'textarea', '', NULL, 0, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:26:51', '2020-09-27 10:26:51', NULL, 1, 0),
(49, 'Nez', 'Au nez', 'textarea', '', NULL, 0, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:27:36', '2020-09-27 10:27:36', NULL, 1, 0),
(50, 'Bouche', 'En bouche', 'textarea', '', NULL, 0, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:30:11', '2020-09-27 10:30:11', NULL, 1, 0),
(51, 'Temperature_de_service', 'Température de service', 'text', '', NULL, 1, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:31:24', '2020-09-27 10:31:24', NULL, 1, 0),
(52, 'A_boire_jusque', 'A boire jusque', 'text', '', NULL, 0, 0, 0, 0, 0, 0, 1, 0, '2020-09-27 10:33:56', '2020-09-27 10:33:56', NULL, 0, 0),
(53, 'Terroir', 'Terroir', 'textarea', '', NULL, 0, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:34:40', '2020-09-27 10:34:40', NULL, 1, 0),
(54, 'Elaboration', 'Elaboration', 'textarea', '', NULL, 0, 0, 0, 0, 0, 0, 1, 1, '2020-09-27 10:35:17', '2020-09-27 10:35:17', NULL, 1, 0),
(55, 'Type_de_culture', 'Type de culture', 'select', '', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 10:37:40', '2020-09-27 10:37:40', 'dropdown', 1, 1),
(56, 'Elevage', 'Élevage', 'select', '', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 14:53:23', '2020-09-27 14:53:23', 'dropdown', 1, 0),
(57, 'Type_de_vendeur', 'Type de vendeur', 'select', '', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 14:57:03', '2020-09-27 14:57:03', 'dropdown', 1, 0),
(58, 'Caracteristiques', 'Caractéristiques', 'multiselect', '', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2020-09-27 15:09:15', '2020-09-27 15:09:15', NULL, 1, 0);

-- --------------------------------------------------------

--
-- Structure de la table `attribute_families`
--

DROP TABLE IF EXISTS `attribute_families`;
CREATE TABLE IF NOT EXISTS `attribute_families` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `is_user_defined` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `attribute_families`
--

INSERT INTO `attribute_families` (`id`, `code`, `name`, `status`, `is_user_defined`) VALUES
(1, 'vin', 'Vin', 0, 1),
(2, 'vin_alsace', 'Vin Alsace', 0, 1);

-- --------------------------------------------------------

--
-- Structure de la table `attribute_groups`
--

DROP TABLE IF EXISTS `attribute_groups`;
CREATE TABLE IF NOT EXISTS `attribute_groups` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `position` int NOT NULL,
  `is_user_defined` tinyint(1) NOT NULL DEFAULT '1',
  `attribute_family_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `attribute_groups_attribute_family_id_name_unique` (`attribute_family_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `attribute_groups`
--

INSERT INTO `attribute_groups` (`id`, `name`, `position`, `is_user_defined`, `attribute_family_id`) VALUES
(1, 'General', 1, 0, 1),
(2, 'Description', 2, 0, 1),
(3, 'Meta Description', 3, 0, 1),
(4, 'Price', 4, 0, 1),
(5, 'Shipping', 5, 0, 1),
(7, 'Général', 1, 1, 2);

-- --------------------------------------------------------

--
-- Structure de la table `attribute_group_mappings`
--

DROP TABLE IF EXISTS `attribute_group_mappings`;
CREATE TABLE IF NOT EXISTS `attribute_group_mappings` (
  `attribute_id` int UNSIGNED NOT NULL,
  `attribute_group_id` int UNSIGNED NOT NULL,
  `position` int DEFAULT NULL,
  PRIMARY KEY (`attribute_id`,`attribute_group_id`),
  KEY `attribute_group_mappings_attribute_group_id_foreign` (`attribute_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `attribute_group_mappings`
--

INSERT INTO `attribute_group_mappings` (`attribute_id`, `attribute_group_id`, `position`) VALUES
(1, 1, 3),
(2, 1, 1),
(3, 1, 3),
(4, 1, 4),
(5, 1, 5),
(6, 1, 6),
(7, 1, 7),
(8, 1, 8),
(9, 2, 1),
(10, 2, 2),
(11, 4, 1),
(12, 4, 2),
(13, 4, 3),
(14, 4, 4),
(15, 4, 5),
(16, 3, 1),
(17, 3, 2),
(18, 3, 3),
(22, 5, 4),
(23, 1, 10),
(25, 1, 12),
(26, 1, 9),
(27, 1, 12),
(29, 1, 2),
(30, 1, 14);

-- --------------------------------------------------------

--
-- Structure de la table `attribute_options`
--

DROP TABLE IF EXISTS `attribute_options`;
CREATE TABLE IF NOT EXISTS `attribute_options` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int DEFAULT NULL,
  `attribute_id` int UNSIGNED NOT NULL,
  `swatch_value` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `attribute_options_attribute_id_foreign` (`attribute_id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `attribute_options`
--

INSERT INTO `attribute_options` (`id`, `admin_name`, `sort_order`, `attribute_id`, `swatch_value`) VALUES
(1, 'Rouge', 1, 23, NULL),
(5, 'Blanc', 2, 23, NULL),
(10, 'Rosé', 3, 23, NULL),
(11, 'Alsace', 1, 27, NULL),
(12, 'Beaujolais', 2, 27, NULL),
(13, 'Bordeaux', 3, 27, NULL),
(14, 'Bourgogne', 4, 27, NULL),
(15, 'Corse', 5, 27, NULL),
(16, 'Jura', 6, 27, NULL),
(17, 'Languedoc', 7, 27, NULL),
(18, 'Languedoc-Roussillon', 8, 27, NULL),
(19, 'Loire', 9, 27, NULL),
(20, 'Bourgogne - Mâconnais', 10, 27, NULL),
(21, 'Pays Basque ', 11, 27, NULL),
(22, 'Provence', 12, 27, NULL),
(23, 'Rhône', 13, 27, NULL),
(24, 'Sud-Ouest', 14, 27, NULL),
(25, 'Vin de france', 15, 27, NULL),
(31, 'AOP', 1, 30, NULL),
(32, 'Aucune', 0, 30, NULL),
(33, 'France', 1, 31, NULL),
(34, '1900', 1, 32, NULL),
(35, 'Un carton de 6 Bouteilles (75cl)', 1, 33, NULL),
(36, 'Un carton de 2 Bouteilles (75cl)', 10, 33, NULL),
(37, 'Un carton de 12 Bouteilles (75cl)', 2, 33, NULL),
(38, 'Carton', 1, 35, NULL),
(39, 'Caisse en bois', 2, 35, NULL),
(40, 'MD : Mis en bouteille au Domaine', 1, 37, NULL),
(41, 'MDC : Mis en bouteille au Château', 2, 37, NULL),
(42, 'MN : Mis en bouteille par le négociant', 3, 37, NULL),
(43, 'MO : Mis en bouteille dans le pays d’origine (pour les vins étrangers)', 4, 37, NULL),
(44, 'MP : Mis en bouteille à la Propriété', 5, 37, NULL),
(45, 'MRP : Mis en bouteille dans la région de production', 6, 37, NULL),
(46, 'Concourt agricole', 1, 40, NULL),
(47, 'Destockage', 1, 41, NULL),
(48, 'Fin de lot', 2, 41, NULL),
(49, '2-5 ans', 1, 44, NULL),
(50, 'Bouchon liège', 1, 47, NULL),
(51, 'Capsule à vis', 2, 47, NULL),
(52, 'Agriculture Conventionnelle', 1, 55, NULL),
(53, 'Agriculture raisonnée', 2, 55, NULL),
(54, 'Agriculture Biologique', 3, 55, NULL),
(55, 'Producteur', 1, 57, NULL),
(56, 'Négociant', 2, 57, NULL),
(57, 'Distributeur', 3, 57, NULL),
(58, 'Livraison gratuite', 5, 41, NULL),
(59, 'Promotions', 3, 41, NULL),
(60, 'Bio', 1, 58, NULL),
(61, 'Cacher', 2, 58, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `attribute_option_translations`
--

DROP TABLE IF EXISTS `attribute_option_translations`;
CREATE TABLE IF NOT EXISTS `attribute_option_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `attribute_option_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `attribute_option_translations_attribute_option_id_locale_unique` (`attribute_option_id`,`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=184 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `attribute_option_translations`
--

INSERT INTO `attribute_option_translations` (`id`, `locale`, `label`, `attribute_option_id`) VALUES
(1, 'en', 'Red', 1),
(5, 'en', 'White', 5),
(18, 'fr', 'Rouge', 1),
(19, 'nl', '', 1),
(26, 'fr', 'Blanc', 5),
(27, 'nl', '', 5),
(28, 'en', 'Pink', 10),
(29, 'fr', 'Rosé', 10),
(30, 'nl', '', 10),
(31, 'en', 'Alsace', 11),
(32, 'fr', 'Alsace', 11),
(33, 'nl', '', 11),
(34, 'en', 'Beaujolais', 12),
(35, 'fr', 'Beaujolais', 12),
(36, 'nl', '', 12),
(37, 'en', 'Bordeaux', 13),
(38, 'fr', 'Bordeaux', 13),
(39, 'nl', '', 13),
(40, 'en', 'Bourgogne', 14),
(41, 'fr', 'Bourgogne', 14),
(42, 'nl', '', 14),
(43, 'en', 'Corse', 15),
(44, 'fr', 'Corse', 15),
(45, 'nl', '', 15),
(46, 'en', 'Jura', 16),
(47, 'fr', 'Jura', 16),
(48, 'nl', '', 16),
(49, 'en', 'Languedoc', 17),
(50, 'fr', 'Languedoc', 17),
(51, 'nl', '', 17),
(52, 'en', 'Languedoc-Roussillon', 18),
(53, 'fr', 'Languedoc-Roussillon', 18),
(54, 'nl', '', 18),
(55, 'en', 'Loire', 19),
(56, 'fr', 'Loire', 19),
(57, 'nl', '', 19),
(58, 'en', 'Bourgogne - Mâconnais', 20),
(59, 'fr', 'Bourgogne - Mâconnais', 20),
(60, 'nl', '', 20),
(61, 'en', 'Pays Basque', 21),
(62, 'fr', 'Pays Basque', 21),
(63, 'nl', '', 21),
(64, 'en', 'Provence', 22),
(65, 'fr', 'Provence', 22),
(66, 'nl', '', 22),
(67, 'en', 'Rhône', 23),
(68, 'fr', 'Rhône', 23),
(69, 'nl', '', 23),
(70, 'en', 'Sud-Ouest', 24),
(71, 'fr', 'Sud-Ouest ', 24),
(72, 'nl', '', 24),
(73, 'en', 'Vin de france', 25),
(74, 'fr', 'Vin de france', 25),
(75, 'nl', '', 25),
(91, 'en', 'AOP', 31),
(92, 'fr', 'AOP', 31),
(93, 'nl', '', 31),
(94, 'en', 'Aucune', 32),
(95, 'fr', 'Aucune', 32),
(96, 'nl', '', 32),
(97, 'en', 'French', 33),
(98, 'fr', 'France', 33),
(99, 'nl', '', 33),
(100, 'en', '1900', 34),
(101, 'fr', '1900', 34),
(102, 'nl', '', 34),
(103, 'en', 'Un carton de 6 Bouteilles (75cl)', 35),
(104, 'fr', 'Un carton de 6 Bouteilles (75cl)', 35),
(105, 'nl', '', 35),
(106, 'en', 'Un carton de 2 Bouteilles (75cl)', 36),
(107, 'fr', 'Un carton de 2 Bouteilles (75cl)', 36),
(108, 'nl', '', 36),
(109, 'en', 'Un carton de 12 Bouteilles (75cl)', 37),
(110, 'fr', 'Un carton de 12 Bouteilles (75cl)', 37),
(111, 'nl', '', 37),
(112, 'en', 'Carton', 38),
(113, 'fr', 'Carton', 38),
(114, 'nl', '', 38),
(115, 'en', 'Caisse en bois', 39),
(116, 'fr', 'Caisse en bois', 39),
(117, 'nl', '', 39),
(118, 'en', 'MD : Mis en bouteille au Domaine', 40),
(119, 'fr', 'MD : Mis en bouteille au Domaine', 40),
(120, 'nl', '', 40),
(121, 'en', 'MDC : Mis en bouteille au Château', 41),
(122, 'fr', 'MDC : Mis en bouteille au Château', 41),
(123, 'nl', '', 41),
(124, 'en', 'MN : Mis en bouteille par le négociant', 42),
(125, 'fr', 'MN : Mis en bouteille par le négociant', 42),
(126, 'nl', '', 42),
(127, 'en', 'MO : Mis en bouteille dans le pays d’origine (pour les vins étrangers)', 43),
(128, 'fr', 'MO : Mis en bouteille dans le pays d’origine (pour les vins étrangers)', 43),
(129, 'nl', '', 43),
(130, 'en', 'MP : Mis en bouteille à la Propriété', 44),
(131, 'fr', 'MP : Mis en bouteille à la Propriété', 44),
(132, 'nl', '', 44),
(133, 'en', 'MRP : Mis en bouteille dans la région de production', 45),
(134, 'fr', 'MRP : Mis en bouteille dans la région de production', 45),
(135, 'nl', '', 45),
(136, 'en', 'Concourt agricole', 46),
(137, 'fr', 'Concourt agricole', 46),
(138, 'nl', '', 46),
(139, 'en', 'Destockage', 47),
(140, 'fr', 'Destockage', 47),
(141, 'nl', '', 47),
(142, 'en', 'Fin de lot', 48),
(143, 'fr', 'Fin de lot', 48),
(144, 'nl', '', 48),
(145, 'en', '2-5 ans', 49),
(146, 'fr', '2-5 ans', 49),
(147, 'nl', '', 49),
(148, 'en', 'Bouchon liège', 50),
(149, 'fr', 'Bouchon liège', 50),
(150, 'nl', '', 50),
(151, 'en', 'Capsule à vis', 51),
(152, 'fr', 'Capsule à vis', 51),
(153, 'nl', '', 51),
(154, 'en', 'Agriculture Conventionnelle', 52),
(155, 'fr', 'Agriculture Conventionnelle', 52),
(156, 'nl', '', 52),
(157, 'en', 'Agriculture raisonnée', 53),
(158, 'fr', 'Agriculture raisonnée', 53),
(159, 'nl', '', 53),
(160, 'en', 'Agriculture Biologique', 54),
(161, 'fr', 'Agriculture Biologique', 54),
(162, 'nl', '', 54),
(163, 'en', 'Producteur', 55),
(164, 'fr', 'Producteur', 55),
(165, 'nl', '', 55),
(166, 'en', 'Négociant', 56),
(167, 'fr', 'Négociant', 56),
(168, 'nl', '', 56),
(169, 'en', 'Distributeur', 57),
(170, 'fr', 'Distributeur', 57),
(171, 'nl', '', 57),
(172, 'en', 'Livraison gratuite', 58),
(173, 'fr', 'Livraison gratuite', 58),
(174, 'nl', '', 58),
(175, 'en', 'Promotions', 59),
(176, 'fr', 'Promotions', 59),
(177, 'nl', '', 59),
(178, 'en', 'Bio', 60),
(179, 'fr', 'Bio', 60),
(180, 'nl', '', 60),
(181, 'en', 'Cacher', 61),
(182, 'fr', 'Cacher', 61),
(183, 'nl', '', 61);

-- --------------------------------------------------------

--
-- Structure de la table `attribute_translations`
--

DROP TABLE IF EXISTS `attribute_translations`;
CREATE TABLE IF NOT EXISTS `attribute_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `attribute_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `attribute_translations_attribute_id_locale_unique` (`attribute_id`,`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=165 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `attribute_translations`
--

INSERT INTO `attribute_translations` (`id`, `locale`, `name`, `attribute_id`) VALUES
(1, 'en', 'SKU', 1),
(2, 'en', 'Name', 2),
(3, 'en', 'URL Key', 3),
(4, 'en', 'Tax Category', 4),
(5, 'en', 'New', 5),
(6, 'en', 'Featured', 6),
(7, 'en', 'Visible Individually', 7),
(8, 'en', 'Status', 8),
(9, 'en', 'Short Description', 9),
(10, 'en', 'Description', 10),
(11, 'en', 'Price', 11),
(12, 'en', 'Cost', 12),
(13, 'en', 'Special Price', 13),
(14, 'en', 'Special Price From', 14),
(15, 'en', 'Special Price To', 15),
(16, 'en', 'Meta Description', 16),
(17, 'en', 'Meta Keywords', 17),
(18, 'en', 'Meta Description', 18),
(22, 'en', 'Weight', 22),
(23, 'en', 'Color', 23),
(25, 'en', 'Brand', 25),
(26, 'en', 'Allow Guest Checkout', 26),
(27, 'fr', 'Marque/Domaine', 25),
(28, 'nl', '', 25),
(31, 'fr', 'Couleur', 23),
(32, 'nl', '', 23),
(33, 'fr', 'Poid', 22),
(34, 'nl', '', 22),
(41, 'fr', 'Prix spécial à partir de', 15),
(42, 'nl', '', 15),
(43, 'fr', 'Prix spécial jusqu\'à', 14),
(44, 'nl', '', 14),
(45, 'fr', 'Prix spécial', 13),
(46, 'nl', '', 13),
(47, 'fr', 'Coût', 12),
(48, 'nl', '', 12),
(49, 'fr', 'Prix', 11),
(50, 'nl', '', 11),
(51, 'fr', 'Description courte', 9),
(52, 'nl', '', 9),
(53, 'fr', 'Statut', 8),
(54, 'nl', '', 8),
(55, 'fr', 'Visible Individuellement', 7),
(56, 'nl', '', 7),
(57, 'fr', 'Populaire', 6),
(58, 'nl', '', 6),
(59, 'fr', 'Nouveau', 5),
(60, 'nl', '', 5),
(61, 'fr', 'Catégorie de taxe', 4),
(62, 'nl', '', 4),
(63, 'fr', 'Clés URL', 3),
(64, 'nl', '', 3),
(65, 'fr', 'Nom', 2),
(66, 'nl', '', 2),
(67, 'fr', 'Vérification des invités', 26),
(68, 'nl', '', 26),
(69, 'en', 'Région', 27),
(70, 'fr', 'Région', 27),
(71, 'nl', '', 27),
(75, 'en', 'Libéllé commercial', 29),
(76, 'fr', 'Libéllé commercial', 29),
(77, 'nl', '', 29),
(78, 'en', 'Origine', 30),
(79, 'fr', 'Origine', 30),
(80, 'nl', '', 30),
(81, 'en', 'Pays d\'origine', 31),
(82, 'fr', 'Pays d\'origine', 31),
(83, 'nl', '', 31),
(84, 'en', 'Millésime', 32),
(85, 'fr', 'Millésime', 32),
(86, 'nl', '', 32),
(87, 'en', 'Contenance', 33),
(88, 'fr', 'Contenance', 33),
(89, 'nl', '', 33),
(90, 'en', 'EAN', 34),
(91, 'fr', 'EAN', 34),
(92, 'nl', '', 34),
(93, 'en', 'Conditionnement', 35),
(94, 'fr', 'Conditionnement', 35),
(95, 'nl', '', 35),
(96, 'en', 'PCB', 36),
(97, 'fr', 'PCB', 36),
(98, 'nl', '', 36),
(99, 'en', 'Mise en bouteille', 37),
(100, 'fr', 'Mise en bouteille', 37),
(101, 'nl', '', 37),
(108, 'en', 'Récompenses', 40),
(109, 'fr', 'Récompenses', 40),
(110, 'nl', '', 40),
(111, 'en', 'Top affaire', 41),
(112, 'fr', 'Top affaire', 41),
(113, 'nl', '', 41),
(114, 'en', 'Gouts majeur', 42),
(115, 'fr', 'Gouts majeur', 42),
(116, 'nl', '', 42),
(117, 'en', 'Gouts', 43),
(118, 'fr', 'Gouts', 43),
(119, 'nl', '', 43),
(120, 'en', 'Conservation', 44),
(121, 'fr', 'Conservation', 44),
(122, 'nl', '', 44),
(123, 'en', 'Degré d\'alcool', 45),
(124, 'fr', 'Degré d\'alcool', 45),
(125, 'nl', '', 45),
(126, 'en', 'Accords recommandés', 46),
(127, 'fr', 'Accords recommandés', 46),
(128, 'nl', '', 46),
(129, 'en', 'Bouchon', 47),
(130, 'fr', 'Bouchon', 47),
(131, 'nl', '', 47),
(132, 'en', 'A œil', 48),
(133, 'fr', 'A œil', 48),
(134, 'nl', '', 48),
(135, 'en', 'Au nez', 49),
(136, 'fr', 'Au nez', 49),
(137, 'nl', '', 49),
(138, 'en', 'En bouche', 50),
(139, 'fr', 'En bouche', 50),
(140, 'nl', '', 50),
(141, 'en', 'Température de service', 51),
(142, 'fr', 'Température de service', 51),
(143, 'nl', '', 51),
(144, 'en', 'A boire jusque', 52),
(145, 'fr', 'A boire jusque', 52),
(146, 'nl', '', 52),
(147, 'en', 'Terroir', 53),
(148, 'fr', 'Terroir', 53),
(149, 'nl', '', 53),
(150, 'en', 'Elaboration', 54),
(151, 'fr', 'Elaboration', 54),
(152, 'nl', '', 54),
(153, 'en', 'Type de culture', 55),
(154, 'fr', 'Type de culture', 55),
(155, 'nl', '', 55),
(156, 'en', 'Élevage', 56),
(157, 'fr', 'Élevage', 56),
(158, 'nl', '', 56),
(159, 'en', 'Type de vendeur', 57),
(160, 'fr', 'Type de vendeur', 57),
(161, 'nl', '', 57),
(162, 'en', 'Caractéristiques', 58),
(163, 'fr', 'Caractéristiques', 58),
(164, 'nl', '', 58);

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_customer_quotes`
--

DROP TABLE IF EXISTS `b2b_marketplace_customer_quotes`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_customer_quotes` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `quote_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quote_brief` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_customer_quotes_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `b2b_marketplace_customer_quotes`
--

INSERT INTO `b2b_marketplace_customer_quotes` (`id`, `customer_id`, `quote_title`, `quote_brief`, `name`, `company_name`, `address`, `phone`, `created_at`, `updated_at`) VALUES
(1, 1, 'Achat alsace', NULL, 'Calixte MARCHAND', 'Magasin Nice', 'belgique', '0122222222', '2020-09-22 22:13:29', '2020-09-22 22:13:29'),
(2, 1, 'Achat alsace', NULL, 'sfdfsdf', 'Magasin Nice', '2717 Waters ThroughwayNorth Kattie, IA 35142', '0122222222', '2020-09-24 15:42:48', '2020-09-24 15:42:48'),
(3, 1, 'Achat alsace', NULL, 'sfdfsdf', 'Magasin Nice', '2717 Waters ThroughwayNorth Kattie, IA 35142', '0122222222', '2020-09-24 15:46:22', '2020-09-24 15:46:22');

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_customer_quote_items`
--

DROP TABLE IF EXISTS `b2b_marketplace_customer_quote_items`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_customer_quote_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `quantity` int DEFAULT NULL,
  `sample_unit` int DEFAULT NULL,
  `shipping_time` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sample_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quote_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price_per_quantity` decimal(12,4) UNSIGNED NOT NULL DEFAULT '0.0000',
  `sample_price` decimal(12,4) DEFAULT '0.0000',
  `is_requested_quote` tinyint(1) NOT NULL DEFAULT '0',
  `is_sample_price` tinyint(1) NOT NULL DEFAULT '0',
  `is_sample` tinyint(1) NOT NULL DEFAULT '0',
  `is_approve` tinyint(1) NOT NULL DEFAULT '0',
  `product_id` int UNSIGNED NOT NULL,
  `quote_id` int UNSIGNED DEFAULT NULL,
  `supplier_id` int UNSIGNED DEFAULT NULL,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `categories` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_customer_quote_items_product_id_foreign` (`product_id`),
  KEY `b2b_marketplace_customer_quote_items_quote_id_foreign` (`quote_id`),
  KEY `b2b_marketplace_customer_quote_items_supplier_id_foreign` (`supplier_id`),
  KEY `b2b_marketplace_customer_quote_items_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `b2b_marketplace_customer_quote_items`
--

INSERT INTO `b2b_marketplace_customer_quote_items` (`id`, `quantity`, `sample_unit`, `shipping_time`, `description`, `sample_image`, `product_name`, `status`, `quote_status`, `note`, `price_per_quantity`, `sample_price`, `is_requested_quote`, `is_sample_price`, `is_sample`, `is_approve`, `product_id`, `quote_id`, `supplier_id`, `customer_id`, `created_at`, `updated_at`, `categories`) VALUES
(1, 150000, NULL, 0, 'test vvv', NULL, 'Test', 'New', 'New', NULL, '20.0000', '0.0000', 1, 0, 1, 0, 1, 1, NULL, 1, '2020-09-22 22:13:29', '2020-09-22 22:13:29', '[]');

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_customer_supplier_messages`
--

DROP TABLE IF EXISTS `b2b_marketplace_customer_supplier_messages`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_customer_supplier_messages` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_id` int UNSIGNED NOT NULL,
  `receiver_id` int UNSIGNED NOT NULL,
  `sender_is_supplier` tinyint(1) NOT NULL DEFAULT '0',
  `is_new` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_invoices`
--

DROP TABLE IF EXISTS `b2b_marketplace_invoices`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_invoices` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_sent` tinyint(1) NOT NULL DEFAULT '0',
  `total_qty` int DEFAULT NULL,
  `sub_total` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total` decimal(12,4) DEFAULT '0.0000',
  `grand_total` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total` decimal(12,4) DEFAULT '0.0000',
  `shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `invoice_id` int UNSIGNED NOT NULL,
  `b2b_marketplace_order_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_invoices_invoice_id_foreign` (`invoice_id`),
  KEY `b2b_marketplace_invoices_b2b_marketplace_order_id_foreign` (`b2b_marketplace_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_invoice_items`
--

DROP TABLE IF EXISTS `b2b_marketplace_invoice_items`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_invoice_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `b2b_marketplace_invoice_id` int UNSIGNED NOT NULL,
  `invoice_item_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_invoice_items_b2b_marketplace_invoice_id_foreign` (`b2b_marketplace_invoice_id`),
  KEY `b2b_marketplace_invoice_items_invoice_item_id_foreign` (`invoice_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_messages`
--

DROP TABLE IF EXISTS `b2b_marketplace_messages`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_messages` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_new` tinyint(1) NOT NULL,
  `message_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_messages_message_id_foreign` (`message_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `b2b_marketplace_messages`
--

INSERT INTO `b2b_marketplace_messages` (`id`, `message`, `role`, `is_new`, `message_id`, `created_at`, `updated_at`) VALUES
(1, 'test des messages', 'customer', 0, 1, '2020-09-22 20:39:28', '2020-09-24 13:01:59'),
(2, 'je peux avoir votre téléphone\n', 'customer', 0, 1, '2020-09-22 20:53:15', '2020-09-24 13:01:59'),
(3, 'je peux avoir votre téléphone\n', 'customer', 0, 1, '2020-09-22 20:53:23', '2020-09-24 13:01:59'),
(4, 'je peux avoir votre téléphone\n', 'customer', 0, 1, '2020-09-22 20:53:24', '2020-09-24 13:01:59'),
(5, 'je peux avoir votre téléphone\n', 'customer', 0, 1, '2020-09-22 20:53:26', '2020-09-24 13:01:59'),
(6, 'je peux avoir votre téléphone\n', 'customer', 0, 1, '2020-09-22 20:53:26', '2020-09-24 13:01:59'),
(7, 'je peux avoir votre téléphone\n', 'customer', 0, 1, '2020-09-22 20:53:28', '2020-09-24 13:01:59'),
(8, 'je peux avoir votre téléphone\n', 'customer', 0, 1, '2020-09-22 20:53:28', '2020-09-24 13:01:59'),
(9, 'je peux avoir votre téléphone\n', 'customer', 0, 1, '2020-09-22 20:53:28', '2020-09-24 13:01:59'),
(10, 'je peux avoir votre téléphone\n\n\n\n\n', 'customer', 0, 1, '2020-09-22 20:53:40', '2020-09-24 13:02:00'),
(11, 'je peux avoir votre téléphone\n\n\n\n\n', 'customer', 0, 1, '2020-09-22 20:53:54', '2020-09-24 13:02:00'),
(12, 'je peux avoir votre téléphone\n\n\n\n\n', 'customer', 0, 1, '2020-09-22 20:54:02', '2020-09-24 13:02:00'),
(13, 'je peux avoir votre téléphone\n\n\n\n\n', 'customer', 0, 1, '2020-09-22 20:54:04', '2020-09-24 13:02:00'),
(14, 'je peux avoir votre téléphone\n\n\n\n\n', 'customer', 0, 1, '2020-09-22 20:54:05', '2020-09-24 13:02:00'),
(15, 'je peux avoir votre téléphone\n\n\n\n\n', 'customer', 0, 1, '2020-09-22 20:54:05', '2020-09-24 13:02:00'),
(16, 'je peux avoir votre téléphone\n\n\n\n\n', 'customer', 0, 1, '2020-09-22 20:54:06', '2020-09-24 13:02:00'),
(17, 'test 1', 'customer', 0, 1, '2020-09-22 20:55:26', '2020-09-24 13:02:00'),
(18, 'test', 'customer', 0, 1, '2020-09-22 21:22:46', '2020-09-24 13:02:00'),
(19, 'test vv', 'customer', 0, 1, '2020-09-22 21:23:52', '2020-09-24 13:02:00'),
(20, 'tesrt xxws', 'customer', 0, 1, '2020-09-22 21:25:17', '2020-09-24 13:02:00'),
(21, 'test', 'customer', 0, 1, '2020-09-22 22:02:22', '2020-09-24 13:02:00'),
(22, 'test 2', 'customer', 0, 1, '2020-09-22 22:05:02', '2020-09-24 13:02:00');

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_message_mappings`
--

DROP TABLE IF EXISTS `b2b_marketplace_message_mappings`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_message_mappings` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED NOT NULL,
  `supplier_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_message_mappings_customer_id_foreign` (`customer_id`),
  KEY `b2b_marketplace_message_mappings_supplier_id_foreign` (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `b2b_marketplace_message_mappings`
--

INSERT INTO `b2b_marketplace_message_mappings` (`id`, `customer_id`, `supplier_id`, `created_at`, `updated_at`) VALUES
(1, 1, 2, '2020-09-22 20:39:28', '2020-09-22 22:05:02');

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_orders`
--

DROP TABLE IF EXISTS `b2b_marketplace_orders`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_orders` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_withdrawal_requested` tinyint(1) NOT NULL DEFAULT '0',
  `supplier_payout_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commission_percentage` decimal(12,4) DEFAULT '0.0000',
  `commission` decimal(12,4) DEFAULT '0.0000',
  `base_commission` decimal(12,4) DEFAULT '0.0000',
  `commission_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_commission_invoiced` decimal(12,4) DEFAULT '0.0000',
  `supplier_total` decimal(12,4) DEFAULT '0.0000',
  `base_supplier_total` decimal(12,4) DEFAULT '0.0000',
  `supplier_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_supplier_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `total_item_count` int DEFAULT NULL,
  `total_qty_ordered` int DEFAULT NULL,
  `grand_total` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total` decimal(12,4) DEFAULT '0.0000',
  `grand_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `grand_total_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total_refunded` decimal(12,4) DEFAULT '0.0000',
  `sub_total` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total` decimal(12,4) DEFAULT '0.0000',
  `sub_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `sub_total_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total_refunded` decimal(12,4) DEFAULT '0.0000',
  `discount_percent` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `discount_amount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `discount_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_discount_refunded` decimal(12,4) DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `tax_amount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `tax_amount_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount_refunded` decimal(12,4) DEFAULT '0.0000',
  `shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `shipping_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_invoiced` decimal(12,4) DEFAULT '0.0000',
  `shipping_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_refunded` decimal(12,4) DEFAULT '0.0000',
  `order_id` int UNSIGNED NOT NULL,
  `supplier_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `b2b_mp_products_supplier_id_order_id_unique` (`supplier_id`,`order_id`),
  KEY `b2b_marketplace_orders_order_id_foreign` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_order_items`
--

DROP TABLE IF EXISTS `b2b_marketplace_order_items`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_order_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `commission` decimal(12,4) DEFAULT '0.0000',
  `base_commission` decimal(12,4) DEFAULT '0.0000',
  `commission_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_commission_invoiced` decimal(12,4) DEFAULT '0.0000',
  `supplier_total` decimal(12,4) DEFAULT '0.0000',
  `base_supplier_total` decimal(12,4) DEFAULT '0.0000',
  `supplier_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_supplier_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `order_item_id` int UNSIGNED NOT NULL,
  `b2b_marketplace_product_id` int UNSIGNED DEFAULT NULL,
  `b2b_marketplace_order_id` int UNSIGNED NOT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_order_items_order_item_id_foreign` (`order_item_id`),
  KEY `b2b_marketplace_order_items_b2b_marketplace_product_id_foreign` (`b2b_marketplace_product_id`),
  KEY `b2b_marketplace_order_items_b2b_marketplace_order_id_foreign` (`b2b_marketplace_order_id`),
  KEY `b2b_marketplace_order_items_parent_id_foreign` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_products`
--

DROP TABLE IF EXISTS `b2b_marketplace_products`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `condition` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` double NOT NULL DEFAULT '0',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_approved` tinyint(1) DEFAULT NULL,
  `is_owner` tinyint(1) NOT NULL DEFAULT '0',
  `parent_id` int UNSIGNED DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `supplier_id` int UNSIGNED NOT NULL,
  `quote_product_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `b2b_mp_products_supplier_id_product_id_unique` (`supplier_id`,`product_id`),
  KEY `b2b_marketplace_products_product_id_foreign` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `b2b_marketplace_products`
--

INSERT INTO `b2b_marketplace_products` (`id`, `condition`, `price`, `description`, `is_approved`, `is_owner`, `parent_id`, `product_id`, `supplier_id`, `quote_product_id`, `created_at`, `updated_at`) VALUES
(1, NULL, 0, NULL, 1, 1, NULL, 1, 2, NULL, '2020-09-22 07:34:23', '2020-09-22 22:35:36'),
(2, NULL, 0, NULL, 0, 1, NULL, 7, 2, NULL, '2020-10-07 09:27:20', '2020-10-07 09:27:20'),
(3, NULL, 0, NULL, 0, 1, NULL, 8, 2, NULL, '2020-10-12 17:08:34', '2020-10-12 17:08:34');

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_product_images`
--

DROP TABLE IF EXISTS `b2b_marketplace_product_images`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_product_images` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `b2b_marketplace_product_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_mp_products_images_foreign` (`b2b_marketplace_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_quote`
--

DROP TABLE IF EXISTS `b2b_marketplace_quote`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_quote` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `quote_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quote_brief` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_quote_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_quote_attachments`
--

DROP TABLE IF EXISTS `b2b_marketplace_quote_attachments`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_quote_attachments` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_quote_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_quote_attachments_customer_quote_id_foreign` (`customer_quote_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_quote_images`
--

DROP TABLE IF EXISTS `b2b_marketplace_quote_images`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_quote_images` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` int UNSIGNED DEFAULT NULL,
  `customer_quote_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_quote_images_customer_quote_id_foreign` (`customer_quote_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_quote_messages`
--

DROP TABLE IF EXISTS `b2b_marketplace_quote_messages`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_quote_messages` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `message` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `supplier_id` int UNSIGNED DEFAULT NULL,
  `customer_quote_item_id` int UNSIGNED DEFAULT NULL,
  `supplier_quote_item_id` int UNSIGNED DEFAULT NULL,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_quote_messages_supplier_id_foreign` (`supplier_id`),
  KEY `b2b_marketplace_quote_messages_customer_quote_item_id_foreign` (`customer_quote_item_id`),
  KEY `b2b_marketplace_quote_messages_supplier_quote_item_id_foreign` (`supplier_quote_item_id`),
  KEY `b2b_marketplace_quote_messages_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_quote_products`
--

DROP TABLE IF EXISTS `b2b_marketplace_quote_products`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_quote_products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `quantity` int DEFAULT NULL,
  `sample_unit` int DEFAULT NULL,
  `shipping_time` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sample_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price_per_quantity` decimal(12,4) UNSIGNED NOT NULL DEFAULT '0.0000',
  `sample_price` decimal(12,4) DEFAULT '0.0000',
  `is_requested_quote` tinyint(1) NOT NULL DEFAULT '0',
  `is_sample_price` tinyint(1) NOT NULL DEFAULT '0',
  `is_sample` tinyint(1) NOT NULL DEFAULT '0',
  `product_id` int UNSIGNED NOT NULL,
  `quote_id` int UNSIGNED DEFAULT NULL,
  `supplier_id` int UNSIGNED DEFAULT NULL,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `is_approve` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_quote_products_product_id_foreign` (`product_id`),
  KEY `b2b_marketplace_quote_products_quote_id_foreign` (`quote_id`),
  KEY `b2b_marketplace_quote_products_supplier_id_foreign` (`supplier_id`),
  KEY `b2b_marketplace_quote_products_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_shipments`
--

DROP TABLE IF EXISTS `b2b_marketplace_shipments`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_shipments` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `total_qty` int DEFAULT NULL,
  `shipment_id` int UNSIGNED NOT NULL,
  `b2b_marketplace_order_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_shipments_shipment_id_foreign` (`shipment_id`),
  KEY `b2b_marketplace_shipments_b2b_marketplace_order_id_foreign` (`b2b_marketplace_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_shipment_items`
--

DROP TABLE IF EXISTS `b2b_marketplace_shipment_items`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_shipment_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `b2b_marketplace_shipment_id` int UNSIGNED NOT NULL,
  `b2b_shipment_item_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_mp_shipment_items_id` (`b2b_marketplace_shipment_id`),
  KEY `b2b_marketplace_shipment_items_b2b_shipment_item_id_foreign` (`b2b_shipment_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_stripe_cards`
--

DROP TABLE IF EXISTS `b2b_marketplace_stripe_cards`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_stripe_cards` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_four` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `misc` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_stripe_cards_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_stripe_cart`
--

DROP TABLE IF EXISTS `b2b_marketplace_stripe_cart`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_stripe_cart` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `cart_id` int UNSIGNED NOT NULL,
  `stripe_token` json NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_stripe_cart_cart_id_foreign` (`cart_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_stripe_suppliers`
--

DROP TABLE IF EXISTS `b2b_marketplace_stripe_suppliers`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_stripe_suppliers` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `access_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `refresh_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `stripe_publishable_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `stripe_user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `marketplace_seller_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_stripe_suppliers_marketplace_seller_id_foreign` (`marketplace_seller_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_suppliers`
--

DROP TABLE IF EXISTS `b2b_marketplace_suppliers`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_suppliers` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `channel_id` int UNSIGNED NOT NULL,
  `first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `gender` enum('Male','Female') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_of_birth` date DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `subscribed_to_news_letter` tinyint(1) NOT NULL DEFAULT '0',
  `is_approved` tinyint(1) NOT NULL DEFAULT '0',
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `b2b_marketplace_suppliers_email_unique` (`email`),
  UNIQUE KEY `b2b_marketplace_suppliers_url_unique` (`url`),
  KEY `b2b_marketplace_suppliers_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `b2b_marketplace_suppliers`
--

INSERT INTO `b2b_marketplace_suppliers` (`id`, `channel_id`, `first_name`, `last_name`, `email`, `password`, `url`, `company_name`, `status`, `gender`, `date_of_birth`, `notes`, `subscribed_to_news_letter`, `is_approved`, `is_verified`, `token`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 1, 'ha', 'ja', 'sdds@m.com', '$2y$10$cnLCLT4TF.UMTenpIunnUeNpye81h1I0NjWtV3bYROvTPQ33dz5nO', 'z', 'z', 1, 'Male', NULL, NULL, 0, 1, 1, 'ef2133a262704feff8fca30a57f810e2', NULL, '2020-08-08 04:35:36', '2020-08-08 04:35:36'),
(2, 1, 'calixte', 'marchand', 'cmarchand@netysoft.com', '$2y$10$61ziseBoybFdvPmsTtd7BurKoCojIOjyemzQlI7uyhLhxHeYCOBe.', 'netysoft', 'netysoft', 1, 'Male', NULL, NULL, 0, 1, 1, '9d6e6b6bb53a89f448c23988003577c2', NULL, '2020-09-18 18:08:23', '2020-09-18 18:08:23');

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_supplier_addresses`
--

DROP TABLE IF EXISTS `b2b_marketplace_supplier_addresses`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_supplier_addresses` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `supplier_id` int UNSIGNED NOT NULL,
  `address1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `postcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default_address` tinyint(1) NOT NULL DEFAULT '0',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `banner` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tax_vat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_tag_line` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registerd_in` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `certification` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `company_overview` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_keywords` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `return_policy` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `shipping_policy` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `privacy_policy` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `twitter` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `facebook` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `youtube` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instagram` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `skype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `linked_in` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pinterest` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `team_size` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `designation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `response_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corporate_address1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corporate_address2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corporate_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corporate_state` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corporate_city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corporate_country` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `corporate_postcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_supplier_addresses_supplier_id_foreign` (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `b2b_marketplace_supplier_addresses`
--

INSERT INTO `b2b_marketplace_supplier_addresses` (`id`, `supplier_id`, `address1`, `address2`, `phone`, `state`, `city`, `country`, `postcode`, `default_address`, `description`, `banner`, `logo`, `tax_vat`, `url`, `company_name`, `company_tag_line`, `registerd_in`, `certification`, `company_overview`, `meta_title`, `meta_description`, `meta_keywords`, `return_policy`, `shipping_policy`, `privacy_policy`, `twitter`, `facebook`, `youtube`, `instagram`, `skype`, `linked_in`, `pinterest`, `created_at`, `updated_at`, `team_size`, `designation`, `response_time`, `corporate_address1`, `corporate_address2`, `corporate_phone`, `corporate_state`, `corporate_city`, `corporate_country`, `corporate_postcode`) VALUES
(1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '', NULL, NULL, NULL, 'z', 'z', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '', NULL, NULL, NULL, 'netysoft', 'netysoft', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_supplier_categories`
--

DROP TABLE IF EXISTS `b2b_marketplace_supplier_categories`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_supplier_categories` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `supplier_id` int UNSIGNED NOT NULL,
  `category_id` int UNSIGNED NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_supplier_categories_supplier_id_foreign` (`supplier_id`),
  KEY `b2b_marketplace_supplier_categories_category_id_foreign` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_supplier_quote_item`
--

DROP TABLE IF EXISTS `b2b_marketplace_supplier_quote_item`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_supplier_quote_item` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quote_quantity` int DEFAULT NULL,
  `quote_price` decimal(12,4) DEFAULT '0.0000',
  `sample_unit` int DEFAULT NULL,
  `is_sample_price` tinyint(1) NOT NULL DEFAULT '0',
  `sample_price` decimal(12,4) DEFAULT '0.0000',
  `shipping_time` int NOT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `supplier_id` int UNSIGNED DEFAULT NULL,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `product_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_supplier_quote_item_supplier_id_foreign` (`supplier_id`),
  KEY `b2b_marketplace_supplier_quote_item_customer_id_foreign` (`customer_id`),
  KEY `b2b_marketplace_supplier_quote_item_product_id_foreign` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_supplier_quote_items`
--

DROP TABLE IF EXISTS `b2b_marketplace_supplier_quote_items`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_supplier_quote_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `quantity` int DEFAULT NULL,
  `sample_unit` int DEFAULT NULL,
  `shipping_time` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sample_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price_per_quantity` decimal(12,4) UNSIGNED NOT NULL DEFAULT '0.0000',
  `sample_price` decimal(12,4) DEFAULT '0.0000',
  `is_requested_quote` tinyint(1) NOT NULL DEFAULT '0',
  `is_sample_price` tinyint(1) NOT NULL DEFAULT '0',
  `is_sample` tinyint(1) NOT NULL DEFAULT '0',
  `is_approve` tinyint(1) NOT NULL DEFAULT '0',
  `is_ordered` tinyint(1) NOT NULL DEFAULT '0',
  `product_id` int UNSIGNED NOT NULL,
  `quote_id` int UNSIGNED DEFAULT NULL,
  `supplier_id` int UNSIGNED DEFAULT NULL,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_marketplace_supplier_quote_items_product_id_foreign` (`product_id`),
  KEY `b2b_marketplace_supplier_quote_items_quote_id_foreign` (`quote_id`),
  KEY `b2b_marketplace_supplier_quote_items_supplier_id_foreign` (`supplier_id`),
  KEY `b2b_marketplace_supplier_quote_items_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_supplier_reviews`
--

DROP TABLE IF EXISTS `b2b_marketplace_supplier_reviews`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_supplier_reviews` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `rating` int NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `supplier_id` int UNSIGNED NOT NULL,
  `customer_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `b2b_mp_reviews_supplier_id_foreign` (`supplier_id`),
  KEY `b2b_marketplace_supplier_reviews_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_marketplace_transactions`
--

DROP TABLE IF EXISTS `b2b_marketplace_transactions`;
CREATE TABLE IF NOT EXISTS `b2b_marketplace_transactions` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `base_total` decimal(12,4) DEFAULT '0.0000',
  `supplier_id` int UNSIGNED NOT NULL,
  `b2b_marketplace_order_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `b2b_marketplace_transactions_transaction_id_unique` (`transaction_id`),
  KEY `b2b_marketplace_transactions_supplier_id_foreign` (`supplier_id`),
  KEY `b2b_marketplace_transactions_b2b_marketplace_order_id_foreign` (`b2b_marketplace_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `b2b_supplier_password_resets`
--

DROP TABLE IF EXISTS `b2b_supplier_password_resets`;
CREATE TABLE IF NOT EXISTS `b2b_supplier_password_resets` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  KEY `b2b_supplier_password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `qty` int DEFAULT '0',
  `from` int DEFAULT NULL,
  `to` int DEFAULT NULL,
  `order_item_id` int UNSIGNED DEFAULT NULL,
  `booking_product_event_ticket_id` int UNSIGNED DEFAULT NULL,
  `order_id` int UNSIGNED DEFAULT NULL,
  `product_id` int UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bookings_order_id_foreign` (`order_id`),
  KEY `bookings_product_id_foreign` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `booking_products`
--

DROP TABLE IF EXISTS `booking_products`;
CREATE TABLE IF NOT EXISTS `booking_products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `qty` int DEFAULT '0',
  `location` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `show_location` tinyint(1) NOT NULL DEFAULT '0',
  `available_every_week` tinyint(1) DEFAULT NULL,
  `available_from` datetime DEFAULT NULL,
  `available_to` datetime DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_products_product_id_foreign` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `booking_product_appointment_slots`
--

DROP TABLE IF EXISTS `booking_product_appointment_slots`;
CREATE TABLE IF NOT EXISTS `booking_product_appointment_slots` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `duration` int DEFAULT NULL,
  `break_time` int DEFAULT NULL,
  `same_slot_all_days` tinyint(1) DEFAULT NULL,
  `slots` json DEFAULT NULL,
  `booking_product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_product_appointment_slots_booking_product_id_foreign` (`booking_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `booking_product_default_slots`
--

DROP TABLE IF EXISTS `booking_product_default_slots`;
CREATE TABLE IF NOT EXISTS `booking_product_default_slots` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `booking_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration` int DEFAULT NULL,
  `break_time` int DEFAULT NULL,
  `slots` json DEFAULT NULL,
  `booking_product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_product_default_slots_booking_product_id_foreign` (`booking_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `booking_product_event_tickets`
--

DROP TABLE IF EXISTS `booking_product_event_tickets`;
CREATE TABLE IF NOT EXISTS `booking_product_event_tickets` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `price` decimal(12,4) DEFAULT '0.0000',
  `qty` int DEFAULT '0',
  `booking_product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_product_event_tickets_booking_product_id_foreign` (`booking_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `booking_product_event_ticket_translations`
--

DROP TABLE IF EXISTS `booking_product_event_ticket_translations`;
CREATE TABLE IF NOT EXISTS `booking_product_event_ticket_translations` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `booking_product_event_ticket_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `booking_product_event_ticket_translations_locale_unique` (`booking_product_event_ticket_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `booking_product_rental_slots`
--

DROP TABLE IF EXISTS `booking_product_rental_slots`;
CREATE TABLE IF NOT EXISTS `booking_product_rental_slots` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `renting_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `daily_price` decimal(12,4) DEFAULT '0.0000',
  `hourly_price` decimal(12,4) DEFAULT '0.0000',
  `same_slot_all_days` tinyint(1) DEFAULT NULL,
  `slots` json DEFAULT NULL,
  `booking_product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_product_rental_slots_booking_product_id_foreign` (`booking_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `booking_product_table_slots`
--

DROP TABLE IF EXISTS `booking_product_table_slots`;
CREATE TABLE IF NOT EXISTS `booking_product_table_slots` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `price_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `guest_limit` int NOT NULL DEFAULT '0',
  `duration` int NOT NULL,
  `break_time` int NOT NULL,
  `prevent_scheduling_before` int NOT NULL,
  `same_slot_all_days` tinyint(1) DEFAULT NULL,
  `slots` json DEFAULT NULL,
  `booking_product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `booking_product_table_slots_booking_product_id_foreign` (`booking_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart`
--

DROP TABLE IF EXISTS `cart`;
CREATE TABLE IF NOT EXISTS `cart` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_first_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_last_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `coupon_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_gift` tinyint(1) NOT NULL DEFAULT '0',
  `items_count` int DEFAULT NULL,
  `items_qty` decimal(12,4) DEFAULT NULL,
  `exchange_rate` decimal(12,4) DEFAULT NULL,
  `global_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `base_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cart_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grand_total` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total` decimal(12,4) DEFAULT '0.0000',
  `sub_total` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total` decimal(12,4) DEFAULT '0.0000',
  `tax_total` decimal(12,4) DEFAULT '0.0000',
  `base_tax_total` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `checkout_method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_guest` tinyint(1) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `conversion_time` datetime DEFAULT NULL,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `channel_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `applied_cart_rule_ids` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_customer_id_foreign` (`customer_id`),
  KEY `cart_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `cart`
--

INSERT INTO `cart` (`id`, `customer_email`, `customer_first_name`, `customer_last_name`, `shipping_method`, `coupon_code`, `is_gift`, `items_count`, `items_qty`, `exchange_rate`, `global_currency_code`, `base_currency_code`, `channel_currency_code`, `cart_currency_code`, `grand_total`, `base_grand_total`, `sub_total`, `base_sub_total`, `tax_total`, `base_tax_total`, `discount_amount`, `base_discount_amount`, `checkout_method`, `is_guest`, `is_active`, `conversion_time`, `customer_id`, `channel_id`, `created_at`, `updated_at`, `applied_cart_rule_ids`) VALUES
(1, 'cmarchand@netysoft.com', 'calixte', 'marchand', 'free_free', NULL, 0, 1, '10.0000', NULL, 'EUR', 'EUR', 'EUR', 'EUR', '1500.0000', '1500.0000', '1500.0000', '1500.0000', '0.0000', '0.0000', '0.0000', '0.0000', NULL, 0, 1, NULL, 1, 1, '2020-09-22 07:48:27', '2020-10-03 09:58:55', '');

-- --------------------------------------------------------

--
-- Structure de la table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE IF NOT EXISTS `cart_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `quantity` int UNSIGNED NOT NULL DEFAULT '0',
  `sku` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `coupon_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weight` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `total_weight` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_total_weight` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `price` decimal(12,4) NOT NULL DEFAULT '1.0000',
  `base_price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `total` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_total` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `tax_percent` decimal(12,4) DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `discount_percent` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `additional` json DEFAULT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `cart_id` int UNSIGNED NOT NULL,
  `tax_category_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `custom_price` decimal(12,4) DEFAULT NULL,
  `applied_cart_rule_ids` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_items_product_id_foreign` (`product_id`),
  KEY `cart_items_cart_id_foreign` (`cart_id`),
  KEY `cart_items_tax_category_id_foreign` (`tax_category_id`),
  KEY `cart_items_parent_id_foreign` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `cart_items`
--

INSERT INTO `cart_items` (`id`, `quantity`, `sku`, `type`, `name`, `coupon_code`, `weight`, `total_weight`, `base_total_weight`, `price`, `base_price`, `total`, `base_total`, `tax_percent`, `tax_amount`, `base_tax_amount`, `discount_percent`, `discount_amount`, `base_discount_amount`, `additional`, `parent_id`, `product_id`, `cart_id`, `tax_category_id`, `created_at`, `updated_at`, `custom_price`, `applied_cart_rule_ids`) VALUES
(1, 10, '1234', 'simple', 'test', NULL, '150.0000', '1500.0000', '1500.0000', '150.0000', '150.0000', '1500.0000', '1500.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '{\"_token\": \"FPiD5eN0UjttIBVnwg5sk5OYR9yH9xrZDuSUgkVE\", \"quantity\": 10, \"product_id\": \"1\"}', NULL, 1, 1, NULL, '2020-09-22 07:48:28', '2020-10-03 09:58:55', NULL, '');

-- --------------------------------------------------------

--
-- Structure de la table `cart_item_inventories`
--

DROP TABLE IF EXISTS `cart_item_inventories`;
CREATE TABLE IF NOT EXISTS `cart_item_inventories` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `qty` int UNSIGNED NOT NULL DEFAULT '0',
  `inventory_source_id` int UNSIGNED DEFAULT NULL,
  `cart_item_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart_payment`
--

DROP TABLE IF EXISTS `cart_payment`;
CREATE TABLE IF NOT EXISTS `cart_payment` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `method_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cart_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_payment_cart_id_foreign` (`cart_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `cart_payment`
--

INSERT INTO `cart_payment` (`id`, `method`, `method_title`, `cart_id`, `created_at`, `updated_at`) VALUES
(1, 'stripe', NULL, 1, '2020-10-03 09:58:34', '2020-10-03 09:58:34');

-- --------------------------------------------------------

--
-- Structure de la table `cart_rules`
--

DROP TABLE IF EXISTS `cart_rules`;
CREATE TABLE IF NOT EXISTS `cart_rules` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `starts_from` datetime DEFAULT NULL,
  `ends_till` datetime DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `coupon_type` int NOT NULL DEFAULT '1',
  `use_auto_generation` tinyint(1) NOT NULL DEFAULT '0',
  `usage_per_customer` int NOT NULL DEFAULT '0',
  `uses_per_coupon` int NOT NULL DEFAULT '0',
  `times_used` int UNSIGNED NOT NULL DEFAULT '0',
  `condition_type` tinyint(1) NOT NULL DEFAULT '1',
  `conditions` json DEFAULT NULL,
  `end_other_rules` tinyint(1) NOT NULL DEFAULT '0',
  `uses_attribute_conditions` tinyint(1) NOT NULL DEFAULT '0',
  `action_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `discount_quantity` int NOT NULL DEFAULT '1',
  `discount_step` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1',
  `apply_to_shipping` tinyint(1) NOT NULL DEFAULT '0',
  `free_shipping` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart_rule_channels`
--

DROP TABLE IF EXISTS `cart_rule_channels`;
CREATE TABLE IF NOT EXISTS `cart_rule_channels` (
  `cart_rule_id` int UNSIGNED NOT NULL,
  `channel_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`cart_rule_id`,`channel_id`),
  KEY `cart_rule_channels_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart_rule_coupons`
--

DROP TABLE IF EXISTS `cart_rule_coupons`;
CREATE TABLE IF NOT EXISTS `cart_rule_coupons` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `usage_limit` int UNSIGNED NOT NULL DEFAULT '0',
  `usage_per_customer` int UNSIGNED NOT NULL DEFAULT '0',
  `times_used` int UNSIGNED NOT NULL DEFAULT '0',
  `type` int UNSIGNED NOT NULL DEFAULT '0',
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `expired_at` date DEFAULT NULL,
  `cart_rule_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_rule_coupons_cart_rule_id_foreign` (`cart_rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart_rule_coupon_usage`
--

DROP TABLE IF EXISTS `cart_rule_coupon_usage`;
CREATE TABLE IF NOT EXISTS `cart_rule_coupon_usage` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `times_used` int NOT NULL DEFAULT '0',
  `cart_rule_coupon_id` int UNSIGNED NOT NULL,
  `customer_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_rule_coupon_usage_cart_rule_coupon_id_foreign` (`cart_rule_coupon_id`),
  KEY `cart_rule_coupon_usage_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart_rule_customers`
--

DROP TABLE IF EXISTS `cart_rule_customers`;
CREATE TABLE IF NOT EXISTS `cart_rule_customers` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `times_used` bigint UNSIGNED NOT NULL DEFAULT '0',
  `cart_rule_id` int UNSIGNED NOT NULL,
  `customer_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cart_rule_customers_cart_rule_id_foreign` (`cart_rule_id`),
  KEY `cart_rule_customers_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart_rule_customer_groups`
--

DROP TABLE IF EXISTS `cart_rule_customer_groups`;
CREATE TABLE IF NOT EXISTS `cart_rule_customer_groups` (
  `cart_rule_id` int UNSIGNED NOT NULL,
  `customer_group_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`cart_rule_id`,`customer_group_id`),
  KEY `cart_rule_customer_groups_customer_group_id_foreign` (`customer_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart_rule_translations`
--

DROP TABLE IF EXISTS `cart_rule_translations`;
CREATE TABLE IF NOT EXISTS `cart_rule_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cart_rule_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cart_rule_translations_cart_rule_id_locale_unique` (`cart_rule_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cart_shipping_rates`
--

DROP TABLE IF EXISTS `cart_shipping_rates`;
CREATE TABLE IF NOT EXISTS `cart_shipping_rates` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `carrier` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `carrier_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `method_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `method_description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` double DEFAULT '0',
  `base_price` double DEFAULT '0',
  `cart_address_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000',
  PRIMARY KEY (`id`),
  KEY `cart_shipping_rates_cart_address_id_foreign` (`cart_address_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `cart_shipping_rates`
--

INSERT INTO `cart_shipping_rates` (`id`, `carrier`, `carrier_title`, `method`, `method_title`, `method_description`, `price`, `base_price`, `cart_address_id`, `created_at`, `updated_at`, `discount_amount`, `base_discount_amount`) VALUES
(1, 'flatrate', 'Flat Rate', 'flatrate_flatrate', 'Flat Rate', 'Flat Rate Shipping', 10, 10, 4, '2020-10-03 09:58:14', '2020-10-03 09:58:30', '0.0000', '0.0000'),
(2, 'free', 'Frais de port offert', 'free_free', 'Frais de port offert', 'Frais de port offert', 0, 0, 4, '2020-10-03 09:58:14', '2020-10-03 09:58:55', '0.0000', '0.0000');

-- --------------------------------------------------------

--
-- Structure de la table `catalog_rules`
--

DROP TABLE IF EXISTS `catalog_rules`;
CREATE TABLE IF NOT EXISTS `catalog_rules` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `starts_from` date DEFAULT NULL,
  `ends_till` date DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `condition_type` tinyint(1) NOT NULL DEFAULT '1',
  `conditions` json DEFAULT NULL,
  `end_other_rules` tinyint(1) NOT NULL DEFAULT '0',
  `action_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `sort_order` int UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `catalog_rule_channels`
--

DROP TABLE IF EXISTS `catalog_rule_channels`;
CREATE TABLE IF NOT EXISTS `catalog_rule_channels` (
  `catalog_rule_id` int UNSIGNED NOT NULL,
  `channel_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`catalog_rule_id`,`channel_id`),
  KEY `catalog_rule_channels_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `catalog_rule_customer_groups`
--

DROP TABLE IF EXISTS `catalog_rule_customer_groups`;
CREATE TABLE IF NOT EXISTS `catalog_rule_customer_groups` (
  `catalog_rule_id` int UNSIGNED NOT NULL,
  `customer_group_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`catalog_rule_id`,`customer_group_id`),
  KEY `catalog_rule_customer_groups_customer_group_id_foreign` (`customer_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `catalog_rule_products`
--

DROP TABLE IF EXISTS `catalog_rule_products`;
CREATE TABLE IF NOT EXISTS `catalog_rule_products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `starts_from` datetime DEFAULT NULL,
  `ends_till` datetime DEFAULT NULL,
  `end_other_rules` tinyint(1) NOT NULL DEFAULT '0',
  `action_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `sort_order` int UNSIGNED NOT NULL DEFAULT '0',
  `product_id` int UNSIGNED NOT NULL,
  `customer_group_id` int UNSIGNED NOT NULL,
  `catalog_rule_id` int UNSIGNED NOT NULL,
  `channel_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `catalog_rule_products_product_id_foreign` (`product_id`),
  KEY `catalog_rule_products_customer_group_id_foreign` (`customer_group_id`),
  KEY `catalog_rule_products_catalog_rule_id_foreign` (`catalog_rule_id`),
  KEY `catalog_rule_products_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `catalog_rule_product_prices`
--

DROP TABLE IF EXISTS `catalog_rule_product_prices`;
CREATE TABLE IF NOT EXISTS `catalog_rule_product_prices` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `rule_date` date NOT NULL,
  `starts_from` datetime DEFAULT NULL,
  `ends_till` datetime DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `customer_group_id` int UNSIGNED NOT NULL,
  `catalog_rule_id` int UNSIGNED NOT NULL,
  `channel_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `catalog_rule_product_prices_product_id_foreign` (`product_id`),
  KEY `catalog_rule_product_prices_customer_group_id_foreign` (`customer_group_id`),
  KEY `catalog_rule_product_prices_catalog_rule_id_foreign` (`catalog_rule_id`),
  KEY `catalog_rule_product_prices_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `position` int NOT NULL DEFAULT '0',
  `image` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `_lft` int UNSIGNED NOT NULL DEFAULT '0',
  `_rgt` int UNSIGNED NOT NULL DEFAULT '0',
  `parent_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `display_mode` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'products_and_description',
  `category_icon_path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `categories__lft__rgt_parent_id_index` (`_lft`,`_rgt`,`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `categories`
--

INSERT INTO `categories` (`id`, `position`, `image`, `status`, `_lft`, `_rgt`, `parent_id`, `created_at`, `updated_at`, `display_mode`, `category_icon_path`) VALUES
(1, 1, NULL, 1, 1, 186, NULL, '2020-07-13 09:51:40', '2020-07-13 09:51:40', 'products_and_description', NULL),
(2, 1, NULL, 1, 14, 111, 1, '2020-07-13 14:02:36', '2020-07-13 14:02:36', 'products_and_description', NULL),
(3, 1, NULL, 1, 15, 30, 2, '2020-09-21 12:20:49', '2020-09-27 15:12:00', 'products_and_description', NULL),
(4, 2, NULL, 1, 31, 88, 2, '2020-09-21 12:21:37', '2020-09-27 15:12:00', 'products_and_description', NULL),
(5, 3, NULL, 1, 89, 90, 2, '2020-09-21 12:22:58', '2020-09-27 15:12:03', 'products_and_description', NULL),
(6, 4, NULL, 1, 91, 92, 2, '2020-09-21 12:23:40', '2020-09-27 15:12:03', 'products_and_description', NULL),
(7, 5, NULL, 1, 136, 151, 1, '2020-09-21 12:24:29', '2020-09-23 07:24:13', 'products_and_description', NULL),
(8, 6, NULL, 1, 93, 94, 2, '2020-09-21 12:25:24', '2020-09-27 15:12:03', 'products_and_description', NULL),
(9, 7, NULL, 1, 95, 96, 2, '2020-09-21 12:26:15', '2020-09-27 15:12:03', 'products_and_description', NULL),
(10, 8, NULL, 1, 97, 98, 2, '2020-09-21 12:27:11', '2020-09-27 15:12:03', 'products_and_description', NULL),
(11, 8, NULL, 1, 99, 100, 2, '2020-09-21 12:28:03', '2020-09-27 15:12:03', 'products_and_description', NULL),
(12, 9, NULL, 1, 101, 102, 2, '2020-09-21 12:28:36', '2020-09-27 15:12:03', 'products_and_description', NULL),
(13, 10, NULL, 1, 103, 104, 2, '2020-09-21 12:29:17', '2020-09-27 15:12:03', 'products_and_description', NULL),
(14, 11, NULL, 1, 105, 106, 2, '2020-09-21 12:29:57', '2020-09-27 15:12:03', 'products_and_description', NULL),
(15, 12, NULL, 1, 107, 108, 2, '2020-09-21 12:30:37', '2020-09-27 15:12:03', 'products_and_description', NULL),
(16, 1, NULL, 1, 32, 33, 4, '2020-09-21 12:33:41', '2020-09-27 15:12:01', 'products_and_description', NULL),
(17, 2, NULL, 1, 34, 35, 4, '2020-09-21 12:34:39', '2020-09-27 15:12:01', 'products_and_description', NULL),
(18, 3, NULL, 1, 36, 37, 4, '2020-09-21 12:35:42', '2020-09-27 15:12:01', 'products_and_description', NULL),
(19, 2, NULL, 1, 113, 122, 21, '2020-09-21 12:37:34', '2020-09-23 07:29:44', 'products_and_description', NULL),
(20, 15, NULL, 1, 109, 110, 2, '2020-09-23 07:18:17', '2020-09-27 15:12:03', 'products_and_description', NULL),
(21, 7, NULL, 1, 112, 135, 1, '2020-09-23 07:20:33', '2020-09-23 07:29:44', 'products_and_description', NULL),
(22, 10, NULL, 1, 152, 153, 1, '2020-09-23 07:24:58', '2020-09-23 07:24:58', 'products_and_description', NULL),
(23, 6, NULL, 1, 154, 185, 1, '2020-09-23 07:27:29', '2020-09-23 07:27:29', 'products_and_description', NULL),
(24, 3, NULL, 1, 123, 128, 21, '2020-09-23 07:31:31', '2020-09-23 07:31:31', 'products_and_description', NULL),
(25, 4, NULL, 1, 129, 130, 21, '2020-09-23 07:32:09', '2020-09-23 07:32:09', 'products_and_description', NULL),
(26, 5, NULL, 1, 131, 132, 21, '2020-09-23 07:32:43', '2020-09-23 07:32:43', 'products_and_description', NULL),
(27, 6, NULL, 1, 133, 134, 21, '2020-09-23 07:37:55', '2020-09-23 07:37:55', 'products_and_description', NULL),
(28, 1, NULL, 1, 114, 115, 19, '2020-09-23 08:11:19', '2020-09-23 11:44:49', 'products_and_description', NULL),
(29, 2, NULL, 1, 116, 117, 19, '2020-09-23 08:11:48', '2020-09-23 11:44:49', 'products_and_description', NULL),
(30, 3, NULL, 1, 118, 119, 19, '2020-09-23 08:12:18', '2020-09-23 11:44:49', 'products_and_description', NULL),
(31, 4, NULL, 1, 120, 121, 19, '2020-09-23 08:12:43', '2020-09-23 11:44:49', 'products_and_description', NULL),
(32, 1, NULL, 1, 124, 125, 24, '2020-09-23 08:15:59', '2020-09-23 11:41:52', 'products_and_description', NULL),
(33, 2, NULL, 1, 126, 127, 24, '2020-09-23 08:16:23', '2020-09-23 11:41:52', 'products_and_description', NULL),
(34, 1, NULL, 1, 38, 39, 4, '2020-09-23 11:48:05', '2020-09-27 15:12:01', 'products_and_description', NULL),
(35, 1, NULL, 1, 40, 41, 4, '2020-09-23 11:48:48', '2020-09-27 15:12:01', 'products_and_description', NULL),
(36, 1, NULL, 1, 42, 43, 4, '2020-09-23 11:49:08', '2020-09-27 15:12:01', 'products_and_description', NULL),
(37, 1, NULL, 1, 44, 45, 4, '2020-09-23 11:49:33', '2020-09-27 15:12:01', 'products_and_description', NULL),
(38, 1, NULL, 1, 46, 47, 4, '2020-09-23 11:50:16', '2020-09-27 15:12:01', 'products_and_description', NULL),
(39, 1, NULL, 1, 48, 49, 4, '2020-09-23 11:50:40', '2020-09-27 15:12:01', 'products_and_description', NULL),
(40, 1, NULL, 1, 50, 51, 4, '2020-09-23 11:51:01', '2020-09-27 15:12:01', 'products_and_description', NULL),
(41, 1, NULL, 1, 52, 53, 4, '2020-09-23 11:51:20', '2020-09-27 15:12:01', 'products_and_description', NULL),
(42, 1, NULL, 1, 54, 55, 4, '2020-09-23 11:52:33', '2020-09-27 15:12:01', 'products_and_description', NULL),
(43, 1, NULL, 1, 56, 57, 4, '2020-09-23 11:53:12', '2020-09-27 15:12:01', 'products_and_description', NULL),
(44, 1, NULL, 1, 58, 59, 4, '2020-09-23 11:53:46', '2020-09-27 15:12:02', 'products_and_description', NULL),
(45, 1, NULL, 1, 60, 61, 4, '2020-09-23 11:54:53', '2020-09-27 15:12:02', 'products_and_description', NULL),
(46, 1, NULL, 1, 62, 63, 4, '2020-09-23 11:55:23', '2020-09-27 15:12:02', 'products_and_description', NULL),
(47, 1, NULL, 1, 64, 65, 4, '2020-09-23 11:56:06', '2020-09-27 15:12:02', 'products_and_description', NULL),
(48, 1, NULL, 1, 66, 67, 4, '2020-09-23 11:57:41', '2020-09-27 15:12:02', 'products_and_description', NULL),
(49, 1, NULL, 1, 68, 69, 4, '2020-09-23 11:58:07', '2020-09-27 15:12:02', 'products_and_description', NULL),
(50, 1, NULL, 1, 70, 71, 4, '2020-09-23 11:58:28', '2020-09-27 15:12:02', 'products_and_description', NULL),
(51, 1, NULL, 1, 72, 73, 4, '2020-09-23 11:59:03', '2020-09-27 15:12:02', 'products_and_description', NULL),
(52, 1, NULL, 1, 74, 75, 4, '2020-09-23 11:59:58', '2020-09-27 15:12:02', 'products_and_description', NULL),
(53, 1, NULL, 1, 76, 77, 4, '2020-09-23 12:01:02', '2020-09-27 15:12:02', 'products_and_description', NULL),
(54, 1, NULL, 1, 78, 79, 4, '2020-09-23 12:01:51', '2020-09-27 15:12:02', 'products_and_description', NULL),
(55, 1, NULL, 1, 80, 81, 4, '2020-09-23 12:02:24', '2020-09-27 15:12:02', 'products_and_description', NULL),
(56, 1, NULL, 1, 82, 83, 4, '2020-09-23 12:02:52', '2020-09-27 15:12:02', 'products_and_description', NULL),
(57, 1, NULL, 1, 84, 85, 4, '2020-09-23 12:03:22', '2020-09-27 15:12:02', 'products_and_description', NULL),
(58, 1, NULL, 1, 86, 87, 4, '2020-09-23 12:03:48', '2020-09-27 15:12:03', 'products_and_description', NULL),
(59, 1, NULL, 1, 20, 21, 3, '2020-09-23 12:06:02', '2020-09-27 15:12:00', 'products_and_description', NULL),
(60, 1, NULL, 1, 22, 23, 3, '2020-09-23 12:06:19', '2020-09-27 15:12:00', 'products_and_description', NULL),
(61, 1, NULL, 1, 16, 17, 3, '2020-09-23 12:07:04', '2020-09-27 15:12:00', 'products_and_description', NULL),
(62, 11, NULL, 1, 18, 19, 3, '2020-09-23 12:07:26', '2020-09-27 15:12:00', 'products_and_description', NULL),
(63, 1, NULL, 1, 24, 25, 3, '2020-09-23 12:09:30', '2020-09-27 15:12:00', 'products_and_description', NULL),
(64, 1, NULL, 1, 26, 27, 3, '2020-09-23 12:09:52', '2020-09-27 15:12:00', 'products_and_description', NULL),
(65, 1, NULL, 1, 28, 29, 3, '2020-09-23 12:10:25', '2020-09-27 15:12:00', 'products_and_description', NULL),
(66, 1, NULL, 1, 155, 156, 23, '2020-09-23 12:13:53', '2020-09-23 12:13:53', 'products_and_description', NULL),
(67, 1, NULL, 1, 157, 170, 23, '2020-09-23 12:14:42', '2020-09-23 12:14:42', 'products_and_description', NULL),
(68, 1, NULL, 1, 164, 165, 67, '2020-09-23 12:15:16', '2020-09-23 12:19:38', 'products_and_description', NULL),
(69, 1, NULL, 1, 166, 167, 67, '2020-09-23 12:15:53', '2020-09-23 12:19:59', 'products_and_description', NULL),
(70, 1, NULL, 1, 162, 163, 67, '2020-09-23 12:16:31', '2020-09-23 12:18:50', 'products_and_description', NULL),
(71, 1, NULL, 1, 160, 161, 67, '2020-09-23 12:17:14', '2020-09-23 12:18:32', 'products_and_description', NULL),
(72, 1, NULL, 1, 158, 159, 67, '2020-09-23 12:17:52', '2020-09-23 12:18:15', 'products_and_description', NULL),
(73, 1, NULL, 1, 168, 169, 67, '2020-09-23 12:22:27', '2020-09-23 12:22:27', 'products_and_description', NULL),
(74, 1, NULL, 1, 171, 184, 23, '2020-09-23 12:23:28', '2020-09-23 12:23:28', 'products_and_description', NULL),
(75, 1, NULL, 1, 174, 175, 74, '2020-09-23 12:24:07', '2020-09-23 12:25:02', 'products_and_description', NULL),
(76, 2, NULL, 1, 172, 173, 74, '2020-09-23 12:24:43', '2020-09-23 12:24:43', 'products_and_description', NULL),
(77, 1, NULL, 1, 176, 177, 74, '2020-09-23 12:25:31', '2020-09-23 12:25:31', 'products_and_description', NULL),
(78, 1, NULL, 1, 178, 179, 74, '2020-09-23 12:26:04', '2020-09-23 12:26:04', 'products_and_description', NULL),
(79, 1, NULL, 1, 180, 181, 74, '2020-09-23 12:26:47', '2020-09-23 12:26:47', 'products_and_description', NULL),
(80, 1, NULL, 1, 182, 183, 74, '2020-09-23 12:27:26', '2020-09-23 12:27:26', 'products_and_description', NULL),
(81, 1, NULL, 1, 137, 138, 7, '2020-09-23 12:29:53', '2020-09-23 12:29:53', 'products_and_description', NULL),
(82, 2, NULL, 1, 139, 140, 7, '2020-09-23 12:30:34', '2020-09-23 12:31:25', 'products_and_description', NULL),
(83, 3, NULL, 1, 141, 142, 7, '2020-09-23 12:31:12', '2020-09-23 12:31:12', 'products_and_description', NULL),
(84, 4, NULL, 1, 143, 144, 7, '2020-09-23 12:32:16', '2020-09-23 12:32:16', 'products_and_description', NULL),
(85, 5, NULL, 1, 145, 146, 7, '2020-09-23 12:32:50', '2020-09-23 12:32:50', 'products_and_description', NULL),
(86, 6, NULL, 1, 147, 148, 7, '2020-09-23 12:33:37', '2020-09-23 12:33:37', 'products_and_description', NULL),
(87, 7, NULL, 1, 149, 150, 7, '2020-09-23 12:34:07', '2020-09-23 12:34:07', 'products_and_description', NULL);

--
-- Déclencheurs `categories`
--
DROP TRIGGER IF EXISTS `trig_categories_insert`;
DELIMITER $$
CREATE TRIGGER `trig_categories_insert` AFTER INSERT ON `categories` FOR EACH ROW BEGIN
                            DECLARE urlPath VARCHAR(255);
            DECLARE localeCode VARCHAR(255);
            DECLARE done INT;
            DECLARE curs CURSOR FOR (SELECT category_translations.locale
                    FROM category_translations
                    WHERE category_id = NEW.id);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;


            IF EXISTS (
                SELECT *
                FROM category_translations
                WHERE category_id = NEW.id
            )
            THEN

                OPEN curs;

            	SET done = 0;
                REPEAT
                	FETCH curs INTO localeCode;

                    SELECT get_url_path_of_category(NEW.id, localeCode) INTO urlPath;

                    IF NEW.parent_id IS NULL
                    THEN
                        SET urlPath = '';
                    END IF;

                    UPDATE category_translations
                    SET url_path = urlPath
                    WHERE
                        category_translations.category_id = NEW.id
                        AND category_translations.locale = localeCode;

                UNTIL done END REPEAT;

                CLOSE curs;

            END IF;
            END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `trig_categories_update`;
DELIMITER $$
CREATE TRIGGER `trig_categories_update` AFTER UPDATE ON `categories` FOR EACH ROW BEGIN
                            DECLARE urlPath VARCHAR(255);
            DECLARE localeCode VARCHAR(255);
            DECLARE done INT;
            DECLARE curs CURSOR FOR (SELECT category_translations.locale
                    FROM category_translations
                    WHERE category_id = NEW.id);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;


            IF EXISTS (
                SELECT *
                FROM category_translations
                WHERE category_id = NEW.id
            )
            THEN

                OPEN curs;

            	SET done = 0;
                REPEAT
                	FETCH curs INTO localeCode;

                    SELECT get_url_path_of_category(NEW.id, localeCode) INTO urlPath;

                    IF NEW.parent_id IS NULL
                    THEN
                        SET urlPath = '';
                    END IF;

                    UPDATE category_translations
                    SET url_path = urlPath
                    WHERE
                        category_translations.category_id = NEW.id
                        AND category_translations.locale = localeCode;

                UNTIL done END REPEAT;

                CLOSE curs;

            END IF;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `category_filterable_attributes`
--

DROP TABLE IF EXISTS `category_filterable_attributes`;
CREATE TABLE IF NOT EXISTS `category_filterable_attributes` (
  `category_id` int UNSIGNED NOT NULL,
  `attribute_id` int UNSIGNED NOT NULL,
  KEY `category_filterable_attributes_category_id_foreign` (`category_id`),
  KEY `category_filterable_attributes_attribute_id_foreign` (`attribute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `category_filterable_attributes`
--

INSERT INTO `category_filterable_attributes` (`category_id`, `attribute_id`) VALUES
(2, 11),
(3, 11),
(4, 11),
(5, 11),
(6, 11),
(7, 11),
(8, 11),
(9, 11),
(10, 11),
(11, 11),
(12, 11),
(13, 11),
(14, 11),
(15, 11),
(16, 11),
(17, 11),
(18, 11),
(19, 11),
(20, 11),
(21, 11),
(22, 11),
(23, 11),
(24, 11),
(25, 11),
(26, 11),
(27, 11),
(28, 11),
(29, 11),
(30, 11),
(31, 11),
(32, 11),
(33, 11),
(34, 11),
(35, 11),
(36, 11),
(37, 11),
(38, 11),
(39, 11),
(40, 11),
(41, 11),
(42, 11),
(43, 11),
(44, 11),
(45, 11),
(46, 11),
(47, 11),
(48, 11),
(49, 11),
(50, 11),
(51, 11),
(52, 11),
(53, 11),
(54, 11),
(55, 11),
(56, 11),
(57, 11),
(58, 11),
(59, 11),
(60, 11),
(61, 11),
(62, 11),
(63, 11),
(64, 11),
(65, 11),
(66, 11),
(67, 11),
(68, 11),
(69, 11),
(70, 11),
(71, 11),
(72, 11),
(73, 11),
(74, 11),
(75, 11),
(76, 11),
(77, 11),
(78, 11),
(79, 11),
(80, 11),
(81, 11),
(82, 11),
(83, 11),
(84, 11),
(85, 11),
(86, 11),
(87, 11),
(2, 23),
(2, 27),
(2, 30),
(2, 31),
(2, 32),
(2, 33),
(2, 35),
(2, 37),
(2, 40),
(2, 41),
(2, 42),
(2, 44),
(2, 47),
(2, 55),
(2, 56),
(2, 57),
(2, 58);

-- --------------------------------------------------------

--
-- Structure de la table `category_translations`
--

DROP TABLE IF EXISTS `category_translations`;
CREATE TABLE IF NOT EXISTS `category_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_keywords` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `category_id` int UNSIGNED NOT NULL,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `locale_id` int UNSIGNED DEFAULT NULL,
  `url_path` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'maintained by database triggers',
  PRIMARY KEY (`id`),
  UNIQUE KEY `category_translations_category_id_slug_locale_unique` (`category_id`,`slug`,`locale`),
  KEY `category_translations_locale_id_foreign` (`locale_id`)
) ENGINE=InnoDB AUTO_INCREMENT=260 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `category_translations`
--

INSERT INTO `category_translations` (`id`, `name`, `slug`, `description`, `meta_title`, `meta_description`, `meta_keywords`, `category_id`, `locale`, `locale_id`, `url_path`) VALUES
(1, 'Root', 'root', 'Root', '', '', '', 1, 'en', NULL, ''),
(2, 'Vin', 'vin', '<p>Rayon Vins</p>', '', '', '', 2, 'fr', 2, 'vin'),
(3, 'Rayon', 'rayon', '<p>test de rubrique</p>', '', '', '', 2, 'en', 1, 'rayon'),
(4, 'Rayon', 'rayon', '<p>test de rubrique</p>', '', '', '', 2, 'nl', 3, 'rayon'),
(5, 'Alsace', 'alsace', '<p><a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Alsace\">Alsace</a></p>', 'Alsace', 'Vins de l\'Alsace', 'Vins Alsace', 3, 'fr', 2, 'vin/alsace'),
(6, 'Alsace', 'alsace', '<p><a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Alsace\">Alsace</a></p>', 'Alsace', 'Vins de l\'Alsace', 'Vins Alsace', 3, 'en', 1, 'rayon/alsace'),
(7, 'Alsace', 'alsace', '<p><a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Alsace\">Alsace</a></p>', 'Alsace', 'Vins de l\'Alsace', 'Vins Alsace', 3, 'nl', 3, 'rayon/alsace'),
(8, 'Bordeaux', 'bordeaux', '<p><a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Bordeaux\">Bordeaux</a></p>', 'Bordeaux', 'vins Bordeaux', 'vins Bordeaux', 4, 'fr', 2, 'vin/bordeaux'),
(9, 'Bordeaux', 'bordeaux', '<p><a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Bordeaux\">Bordeaux</a></p>', 'Bordeaux', 'vins Bordeaux', 'vins Bordeaux', 4, 'en', 1, 'rayon/bordeaux'),
(10, 'Bordeaux', 'bordeaux', '<p><a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Bordeaux\">Bordeaux</a></p>', 'Bordeaux', 'vins Bordeaux', 'vins Bordeaux', 4, 'nl', 3, 'rayon/bordeaux'),
(11, 'Beaujolais', 'beaujolais', '<p>Vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Beaujolais\">Beaujolais</a></p>', 'Beaujolais', 'vins Beaujolais', 'vins Beaujolais', 5, 'fr', 2, 'vin/beaujolais'),
(12, 'Beaujolais', 'beaujolais', '<p>Vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Beaujolais\">Beaujolais</a></p>', 'Beaujolais', 'vins Beaujolais', 'vins Beaujolais', 5, 'en', 1, 'rayon/beaujolais'),
(13, 'Beaujolais', 'beaujolais', '<p>Vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Beaujolais\">Beaujolais</a></p>', 'Beaujolais', 'vins Beaujolais', 'vins Beaujolais', 5, 'nl', 3, 'rayon/beaujolais'),
(14, 'Bourgogne', 'bourgogne', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Bourgogne\">Bourgogne</a></p>', 'vins Bourgogne', 'vins Bourgogne', 'vins Bourgogne', 6, 'fr', 2, 'vin/bourgogne'),
(15, 'Bourgogne', 'bourgogne', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Bourgogne\">Bourgogne</a></p>', 'vins Bourgogne', 'vins Bourgogne', 'vins Bourgogne', 6, 'en', 1, 'rayon/bourgogne'),
(16, 'Bourgogne', 'bourgogne', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Bourgogne\">Bourgogne</a></p>', 'vins Bourgogne', 'vins Bourgogne', 'vins Bourgogne', 6, 'nl', 3, 'rayon/bourgogne'),
(17, 'Champagne', 'champagne', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Champagne\">Champagne</a></p>', 'vins Champagne', 'Champagne', 'Champagne', 7, 'fr', 2, 'champagne'),
(18, 'Champagne', 'champagne', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Champagne\">Champagne</a></p>', 'vins Champagne', 'Champagne', 'Champagne', 7, 'en', 1, 'champagne'),
(19, 'Champagne', 'champagne', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Champagne\">Champagne</a></p>', 'vins Champagne', 'Champagne', 'Champagne', 7, 'nl', 3, 'champagne'),
(20, 'Provence-Corse', 'provence-corse', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Corse\">Provence-Corse</a></p>', 'vins Provence-Corse', 'vins Provence-Corse', 'vins Provence-Corse', 8, 'fr', 2, 'vin/provence-corse'),
(21, 'Provence-Corse', 'provence-corse', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Corse\">Provence-Corse</a></p>', 'vins Provence-Corse', 'vins Provence-Corse', 'vins Provence-Corse', 8, 'en', 1, 'rayon/provence-corse'),
(22, 'Provence-Corse', 'provence-corse', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Corse\">Provence-Corse</a></p>', 'vins Provence-Corse', 'vins Provence-Corse', 'vins Provence-Corse', 8, 'nl', 3, 'rayon/provence-corse'),
(23, 'Jura', 'jura', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Jura\">Jura</a></p>', 'viins Jura', 'vins Jura', 'vins Jura', 9, 'fr', 2, 'vin/jura'),
(24, 'Jura', 'jura', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Jura\">Jura</a></p>', 'viins Jura', 'vins Jura', 'vins Jura', 9, 'en', 1, 'rayon/jura'),
(25, 'Jura', 'jura', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Jura\">Jura</a></p>', 'viins Jura', 'vins Jura', 'vins Jura', 9, 'nl', 3, 'rayon/jura'),
(26, 'Languedoc-Roussillon', 'languedoc-roussillon', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Languedoc\">Languedoc-Roussillon</a></p>', 'vins Languedoc-Roussillon', 'vins Languedoc-Roussillon', 'vins Languedoc-Roussillon', 10, 'fr', 2, 'vin/languedoc-roussillon'),
(27, 'Languedoc-Roussillon', 'languedoc-roussillon', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Languedoc\">Languedoc-Roussillon</a></p>', 'vins Languedoc-Roussillon', 'vins Languedoc-Roussillon', 'vins Languedoc-Roussillon', 10, 'en', 1, 'rayon/languedoc-roussillon'),
(28, 'Languedoc-Roussillon', 'languedoc-roussillon', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Languedoc\">Languedoc-Roussillon</a></p>', 'vins Languedoc-Roussillon', 'vins Languedoc-Roussillon', 'vins Languedoc-Roussillon', 10, 'nl', 3, 'rayon/languedoc-roussillon'),
(29, 'Lorraine', 'lorraine', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Lorraine\">Lorraine</a></p>', 'vins Lorraine', 'vins Lorraine', 'vins Lorraine', 11, 'fr', 2, 'vin/lorraine'),
(30, 'Lorraine', 'lorraine', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Lorraine\">Lorraine</a></p>', 'vins Lorraine', 'vins Lorraine', 'vins Lorraine', 11, 'en', 1, 'rayon/lorraine'),
(31, 'Lorraine', 'lorraine', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Lorraine\">Lorraine</a></p>', 'vins Lorraine', 'vins Lorraine', 'vins Lorraine', 11, 'nl', 3, 'rayon/lorraine'),
(32, 'Loire', 'loire', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Loire\">Loire</a></p>', 'vins Loire', 'vins Loire', 'vins Loire', 12, 'fr', 2, 'vin/loire'),
(33, 'Loire', 'loire', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Loire\">Loire</a></p>', 'vins Loire', 'vins Loire', 'vins Loire', 12, 'en', 1, 'rayon/loire'),
(34, 'Loire', 'loire', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Loire\">Loire</a></p>', 'vins Loire', 'vins Loire', 'vins Loire', 12, 'nl', 3, 'rayon/loire'),
(35, 'Rhône', 'rhone', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Rh&ocirc;ne\">Rh&ocirc;ne</a></p>', 'vins Rhône', 'vins Rhône', 'vins Rhône', 13, 'fr', 2, 'vin/rhone'),
(36, 'Rhône', 'rhone', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Rh&ocirc;ne\">Rh&ocirc;ne</a></p>', 'vins Rhône', 'vins Rhône', 'vins Rhône', 13, 'en', 1, 'rayon/rhone'),
(37, 'Rhône', 'rhone', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Rh&ocirc;ne\">Rh&ocirc;ne</a></p>', 'vins Rhône', 'vins Rhône', 'vins Rhône', 13, 'nl', 3, 'rayon/rhone'),
(38, 'Savoie-Bugey', 'savoie-bugey', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Savoie\">Savoie-Bugey</a></p>', 'vins Savoie-Bugey', 'vins Savoie-Bugey', 'vins Savoie-Bugey', 14, 'fr', 2, 'vin/savoie-bugey'),
(39, 'Savoie-Bugey', 'savoie-bugey', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Savoie\">Savoie-Bugey</a></p>', 'vins Savoie-Bugey', 'vins Savoie-Bugey', 'vins Savoie-Bugey', 14, 'en', 1, 'rayon/savoie-bugey'),
(40, 'Savoie-Bugey', 'savoie-bugey', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Savoie\">Savoie-Bugey</a></p>', 'vins Savoie-Bugey', 'vins Savoie-Bugey', 'vins Savoie-Bugey', 14, 'nl', 3, 'rayon/savoie-bugey'),
(41, 'Sud-Ouest', 'sud-ouest', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Sud-Ouest\">Sud-Ouest</a></p>', 'Vins Sud-Ouest', 'vins Sud-Ouest', 'vins Sud-Ouest', 15, 'fr', 2, 'vin/sud-ouest'),
(42, 'Sud-Ouest', 'sud-ouest', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Sud-Ouest\">Sud-Ouest</a></p>', 'Vins Sud-Ouest', 'vins Sud-Ouest', 'vins Sud-Ouest', 15, 'en', 1, 'rayon/sud-ouest'),
(43, 'Sud-Ouest', 'sud-ouest', '<p>vins&nbsp;<a style=\"color: #4c4c4d; font-family: Verdana, Arial, sans-serif, serif, Tahoma, Helvitica; font-size: 12px;\" title=\"Vin Sud-Ouest\">Sud-Ouest</a></p>', 'Vins Sud-Ouest', 'vins Sud-Ouest', 'vins Sud-Ouest', 15, 'nl', 3, 'rayon/sud-ouest'),
(44, 'Médoc', 'medoc', '<p>vins M&eacute;doc</p>', 'vins médoc', 'vins medoc', 'vins medoc', 16, 'fr', 2, 'vin/bordeaux/medoc'),
(45, 'Médoc', 'medoc', '<p>vins M&eacute;doc</p>', 'vins médoc', 'vins medoc', 'vins medoc', 16, 'en', 1, 'rayon/bordeaux/medoc'),
(46, 'Médoc', 'medoc', '<p>vins M&eacute;doc</p>', 'vins médoc', 'vins medoc', 'vins medoc', 16, 'nl', 3, 'rayon/bordeaux/medoc'),
(47, 'Graves', 'graves', '<p>Vins Gr&acirc;ves</p>', 'vins grâves', 'vins grâves', 'vins grâve', 17, 'fr', 2, 'vin/bordeaux/graves'),
(48, 'Graves', 'graves', '<p>Vins Gr&acirc;ves</p>', 'vins grâves', 'vins grâves', 'vins grâve', 17, 'en', 1, 'rayon/bordeaux/graves'),
(49, 'Graves', 'graves', '<p>Vins Gr&acirc;ves</p>', 'vins grâves', 'vins grâves', 'vins grâve', 17, 'nl', 3, 'rayon/bordeaux/graves'),
(50, 'Entre-deux-Mers', 'entre-deux-mers', '<p>Vins entre deux mers</p>', 'vins entre deux mers', 'vins entre deux mers', 'vins entre deux mers', 18, 'fr', 2, 'vin/bordeaux/entre-deux-mers'),
(51, 'Entre-deux-Mers', 'entre-deux-mers', '<p>Vins entre deux mers</p>', 'vins entre deux mers', 'vins entre deux mers', 'vins entre deux mers', 18, 'en', 1, 'rayon/bordeaux/entre-deux-mers'),
(52, 'Entre-deux-Mers', 'entre-deux-mers', '<p>Vins entre deux mers</p>', 'vins entre deux mers', 'vins entre deux mers', 'vins entre deux mers', 18, 'nl', 3, 'rayon/bordeaux/entre-deux-mers'),
(53, 'Wisky', 'wisky', '<p>Wisky</p>', 'wisky', 'wisky', 'wisky', 19, 'fr', 2, 'spiritueux/wisky'),
(54, 'wisky', 'wisky', '<p>Wisky</p>', 'wisky', 'wisky', 'wisky', 19, 'en', 1, 'spiritueux/wisky'),
(55, 'wisky', 'wisky', '<p>Wisky</p>', 'wisky', 'wisky', 'wisky', 19, 'nl', 3, 'spiritueux/wisky'),
(56, 'Vins du monde', 'vins-du-monde', '<p>Vins du monde</p>', '', '', '', 20, 'fr', 2, 'vin/vins-du-monde'),
(57, 'Vins du monde', 'vins-du-monde', '<p>Vins du monde</p>', '', '', '', 20, 'en', 1, 'rayon/vins-du-monde'),
(58, 'Vins du monde', 'vins-du-monde', '<p>Vins du monde</p>', '', '', '', 20, 'nl', 3, 'rayon/vins-du-monde'),
(59, 'Spiritueux', 'spiritueux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">SPIRITUEUX</span></p>', '', '', '', 21, 'fr', 2, 'spiritueux'),
(60, 'SPIRITUEUX', 'spiritueux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">SPIRITUEUX</span></p>', '', '', '', 21, 'en', 1, 'spiritueux'),
(61, 'SPIRITUEUX', 'spiritueux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">SPIRITUEUX</span></p>', '', '', '', 21, 'nl', 3, 'spiritueux'),
(62, 'Bière', 'biere', '<p>Bi&egrave;res</p>', '', '', '', 22, 'fr', 2, 'biere'),
(63, 'Bière', 'biere', '<p>Bi&egrave;res</p>', '', '', '', 22, 'en', 1, 'biere'),
(64, 'Bière', 'biere', '<p>Bi&egrave;res</p>', '', '', '', 22, 'nl', 3, 'biere'),
(65, 'Effervescent', 'effervescent', '<p>Effervescent</p>', '', '', '', 23, 'fr', 2, 'effervescent'),
(66, 'Effervescents', 'effervescents', '<p>Effervescent</p>', '', '', '', 23, 'en', 1, 'effervescents'),
(67, 'Effervescents', 'effervescents', '<p>Effervescent</p>', '', '', '', 23, 'nl', 3, 'effervescents'),
(68, 'Rhum', 'rhum', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums</span></p>', '', '', '', 24, 'fr', 2, 'spiritueux/rhum'),
(69, 'Rhums', 'rhums', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums</span></p>', '', '', '', 24, 'en', 1, 'spiritueux/rhums'),
(70, 'Rhums', 'rhums', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums</span></p>', '', '', '', 24, 'nl', 3, 'spiritueux/rhums'),
(71, 'Gin', 'gin', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Gin</span></p>', '', '', '', 25, 'fr', 2, 'spiritueux/gin'),
(72, 'Gin', 'gin', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Gin</span></p>', '', '', '', 25, 'en', 1, 'spiritueux/gin'),
(73, 'Gin', 'gin', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Gin</span></p>', '', '', '', 25, 'nl', 3, 'spiritueux/gin'),
(74, 'Cognac & Armagnac', 'cognac-armagnac', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cognac &amp; Armagnac</span></p>', '', '', '', 26, 'fr', 2, 'spiritueux/cognac-armagnac'),
(75, 'Cognac & Armagnac', 'cognac-armagnac', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cognac &amp; Armagnac</span></p>', '', '', '', 26, 'en', 1, 'spiritueux/cognac-armagnac'),
(76, 'Cognac & Armagnac', 'cognac-armagnac', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cognac &amp; Armagnac</span></p>', '', '', '', 26, 'nl', 3, 'spiritueux/cognac-armagnac'),
(77, 'Vodka', 'vodka', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Vodka</span></p>', '', '', '', 27, 'fr', 2, 'spiritueux/vodka'),
(78, 'Vodka', 'vodka', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Vodka</span></p>', '', '', '', 27, 'en', 1, 'spiritueux/vodka'),
(79, 'Vodka', 'vodka', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Vodka</span></p>', '', '', '', 27, 'nl', 3, 'spiritueux/vodka'),
(80, 'Whisky Écossais', 'whisky-ecossais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies &Eacute;cossais</span></p>', '', '', '', 28, 'fr', 2, 'wisky/spiritueux/whisky-ecossais'),
(81, 'Whiskies Écossais', 'whiskies-ecossais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies &Eacute;cossais</span></p>', '', '', '', 28, 'en', 1, 'wisky/spiritueux/whiskies-ecossais'),
(82, 'Whiskies Écossais', 'whiskies-ecossais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies &Eacute;cossais</span></p>', '', '', '', 28, 'nl', 3, 'wisky/spiritueux/whiskies-ecossais'),
(83, 'Whisky Américain', 'whisky-americain', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Am&eacute;ricains</span></p>', '', '', '', 29, 'fr', 2, 'wisky/spiritueux/whisky-americain'),
(84, 'Whiskies Américains', 'whiskies-americains', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Am&eacute;ricains</span></p>', '', '', '', 29, 'en', 1, 'wisky/spiritueux/whiskies-americains'),
(85, 'Whiskies Américains', 'whiskies-americains', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Am&eacute;ricains</span></p>', '', '', '', 29, 'nl', 3, 'wisky/spiritueux/whiskies-americains'),
(86, 'Whisky Irlandais', 'whisky-irlandais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Irlandais</span></p>', '', '', '', 30, 'fr', 2, 'wisky/spiritueux/whisky-irlandais'),
(87, 'Whiskies Irlandais', 'whiskies-irlandais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Irlandais</span></p>', '', '', '', 30, 'en', 1, 'wisky/spiritueux/whiskies-irlandais'),
(88, 'Whiskies Irlandais', 'whiskies-irlandais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Irlandais</span></p>', '', '', '', 30, 'nl', 3, 'wisky/spiritueux/whiskies-irlandais'),
(89, 'Whisky Japonais', 'whisky-japonais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Japonais</span></p>', '', '', '', 31, 'fr', 2, 'wisky/spiritueux/whisky-japonais'),
(90, 'Whiskies Japonais', 'whiskies-japonais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Japonais</span></p>', '', '', '', 31, 'en', 1, 'wisky/spiritueux/whiskies-japonais'),
(91, 'Whiskies Japonais', 'whiskies-japonais', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Whiskies Japonais</span></p>', '', '', '', 31, 'nl', 3, 'wisky/spiritueux/whiskies-japonais'),
(92, 'Rhum Ambré', 'rhum-ambre', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums Ambr&eacute;s</span></p>', '', '', '', 32, 'fr', 2, 'spiritueux/rhum/rhum-ambre'),
(93, 'Rhums Ambrés', 'rhums-ambres', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums Ambr&eacute;s</span></p>', '', '', '', 32, 'en', 1, 'spiritueux/rhums/rhums-ambres'),
(94, 'Rhums Ambrés', 'rhums-ambres', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums Ambr&eacute;s</span></p>', '', '', '', 32, 'nl', 3, 'spiritueux/rhums/rhums-ambres'),
(95, 'Rhum Vieux', 'rhum-vieux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums Vieux</span></p>', '', '', '', 33, 'fr', 2, 'spiritueux/rhum/rhum-vieux'),
(96, 'Rhums Vieux', 'rhums-vieux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums Vieux</span></p>', '', '', '', 33, 'en', 1, 'spiritueux/rhums/rhums-vieux'),
(97, 'Rhums Vieux', 'rhums-vieux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Rhums Vieux</span></p>', '', '', '', 33, 'nl', 3, 'spiritueux/rhums/rhums-vieux'),
(98, 'Margaux', 'margaux', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/margaux\">Margaux</a></li>\r\n</ul>', '', '', '', 34, 'fr', 2, 'vin/bordeaux/margaux'),
(99, 'Margaux', 'margaux', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/margaux\">Margaux</a></li>\r\n</ul>', '', '', '', 34, 'en', 1, 'rayon/bordeaux/margaux'),
(100, 'Margaux', 'margaux', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/margaux\">Margaux</a></li>\r\n</ul>', '', '', '', 34, 'nl', 3, 'rayon/bordeaux/margaux'),
(101, 'Saint-Estèphe', 'saint-estephe', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-estephe\">Saint-Est&egrave;phe</a></li>\r\n</ul>', '', '', '', 35, 'fr', 2, 'vin/bordeaux/saint-estephe'),
(102, 'Saint-Estèphe', 'saint-estephe', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-estephe\">Saint-Est&egrave;phe</a></li>\r\n</ul>', '', '', '', 35, 'en', 1, 'rayon/bordeaux/saint-estephe'),
(103, 'Saint-Estèphe', 'saint-estephe', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-estephe\">Saint-Est&egrave;phe</a></li>\r\n</ul>', '', '', '', 35, 'nl', 3, 'rayon/bordeaux/saint-estephe'),
(104, 'Saint-Julien', 'saint-julien', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-julien\">Saint-Julien</a></li>\r\n</ul>', '', '', '', 36, 'fr', 2, 'vin/bordeaux/saint-julien'),
(105, 'Saint-Julien', 'saint-julien', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-julien\">Saint-Julien</a></li>\r\n</ul>', '', '', '', 36, 'en', 1, 'rayon/bordeaux/saint-julien'),
(106, 'Saint-Julien', 'saint-julien', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-julien\">Saint-Julien</a></li>\r\n</ul>', '', '', '', 36, 'nl', 3, 'rayon/bordeaux/saint-julien'),
(107, 'Pauillac', 'pauillac', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/pauillac\">Pauillac</a></li>\r\n</ul>', '', '', '', 37, 'fr', 2, 'vin/bordeaux/pauillac'),
(108, 'Pauillac', 'pauillac', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/pauillac\">Pauillac</a></li>\r\n</ul>', '', '', '', 37, 'en', 1, 'rayon/bordeaux/pauillac'),
(109, 'Pauillac', 'pauillac', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/pauillac\">Pauillac</a></li>\r\n</ul>', '', '', '', 37, 'nl', 3, 'rayon/bordeaux/pauillac'),
(110, 'Sauternes', 'sauternes', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/sauternes\">Sauternes</a></li>\r\n</ul>', '', '', '', 38, 'fr', 2, 'vin/bordeaux/sauternes'),
(111, 'Sauternes', 'sauternes', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/sauternes\">Sauternes</a></li>\r\n</ul>', '', '', '', 38, 'en', 1, 'rayon/bordeaux/sauternes'),
(112, 'Sauternes', 'sauternes', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/sauternes\">Sauternes</a></li>\r\n</ul>', '', '', '', 38, 'nl', 3, 'rayon/bordeaux/sauternes'),
(113, 'Côtes-De-Castillon', 'cotes-de-castillon', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/castillon-cotes-de-bordeaux\">C&ocirc;tes-De-Castillon</a></li>\r\n</ul>', '', '', '', 39, 'fr', 2, 'vin/bordeaux/cotes-de-castillon'),
(114, 'Côtes-De-Castillon', 'cotes-de-castillon', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/castillon-cotes-de-bordeaux\">C&ocirc;tes-De-Castillon</a></li>\r\n</ul>', '', '', '', 39, 'en', 1, 'rayon/bordeaux/cotes-de-castillon'),
(115, 'Côtes-De-Castillon', 'cotes-de-castillon', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/castillon-cotes-de-bordeaux\">C&ocirc;tes-De-Castillon</a></li>\r\n</ul>', '', '', '', 39, 'nl', 3, 'rayon/bordeaux/cotes-de-castillon'),
(116, 'Pomerol', 'pomerol', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/pomerol\">Pomerol</a></li>\r\n</ul>', '', '', '', 40, 'fr', 2, 'vin/bordeaux/pomerol'),
(117, 'Pomerol', 'pomerol', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/pomerol\">Pomerol</a></li>\r\n</ul>', '', '', '', 40, 'en', 1, 'rayon/bordeaux/pomerol'),
(118, 'Pomerol', 'pomerol', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/pomerol\">Pomerol</a></li>\r\n</ul>', '', '', '', 40, 'nl', 3, 'rayon/bordeaux/pomerol'),
(119, 'Saint-Émilion', 'saint-emilion', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-emilion\">Saint-&Eacute;milion</a></li>\r\n</ul>', '', '', '', 41, 'fr', 2, 'vin/bordeaux/saint-emilion'),
(120, 'Saint-Émilion', 'saint-emilion', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-emilion\">Saint-&Eacute;milion</a></li>\r\n</ul>', '', '', '', 41, 'en', 1, 'rayon/bordeaux/saint-emilion'),
(121, 'Saint-Émilion', 'saint-emilion', '<ul style=\"margin: 0px; padding: 0px 15px; list-style: none; overflow: hidden; font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">\r\n<li class=\"\" style=\"margin: 0px; padding: 6px 0px 0px;\"><a style=\"margin: 0px; padding: 0px; color: #666666; font-family: OpenSans; text-decoration-line: none;\" href=\"https://www.lavinia.fr/fr/t/bordeaux/saint-emilion\">Saint-&Eacute;milion</a></li>\r\n</ul>', '', '', '', 41, 'nl', 3, 'rayon/bordeaux/saint-emilion'),
(122, 'Moulis-en-Médoc', 'moulis-en-medoc', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Moulis-en-M&eacute;doc</span></p>', '', '', '', 42, 'fr', 2, 'vin/bordeaux/moulis-en-medoc'),
(123, 'Moulis-en-Médoc', 'moulis-en-medoc', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Moulis-en-M&eacute;doc</span></p>', '', '', '', 42, 'en', 1, 'rayon/bordeaux/moulis-en-medoc'),
(124, 'Moulis-en-Médoc', 'moulis-en-medoc', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Moulis-en-M&eacute;doc</span></p>', '', '', '', 42, 'nl', 3, 'rayon/bordeaux/moulis-en-medoc'),
(125, 'Pessac-Léognan', 'pessac-leognan', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Pessac-L&eacute;ognan</span></p>', '', '', '', 43, 'fr', 2, 'vin/bordeaux/pessac-leognan'),
(126, 'Pessac-Léognan', 'pessac-leognan', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Pessac-L&eacute;ognan</span></p>', '', '', '', 43, 'en', 1, 'rayon/bordeaux/pessac-leognan'),
(127, 'Pessac-Léognan', 'pessac-leognan', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Pessac-L&eacute;ognan</span></p>', '', '', '', 43, 'nl', 3, 'rayon/bordeaux/pessac-leognan'),
(128, 'Francs-Côtes de Bordeaux', 'francs-cotes-de-bordeaux', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Francs-C&ocirc;tes de Bordeaux</span></p>', '', '', '', 44, 'fr', 2, 'vin/bordeaux/francs-cotes-de-bordeaux'),
(129, 'Francs-Côtes de Bordeaux', 'francs-cotes-de-bordeaux', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Francs-C&ocirc;tes de Bordeaux</span></p>', '', '', '', 44, 'en', 1, 'rayon/bordeaux/francs-cotes-de-bordeaux'),
(130, 'Francs-Côtes de Bordeaux', 'francs-cotes-de-bordeaux', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Francs-C&ocirc;tes de Bordeaux</span></p>', '', '', '', 44, 'nl', 3, 'rayon/bordeaux/francs-cotes-de-bordeaux'),
(131, 'Haut-Médoc', 'haut-medoc', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Haut-M&eacute;doc</span></p>', '', '', '', 45, 'fr', 2, 'vin/bordeaux/haut-medoc'),
(132, 'Haut-Médoc', 'haut-medoc', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Haut-M&eacute;doc</span></p>', '', '', '', 45, 'en', 1, 'rayon/bordeaux/haut-medoc'),
(133, 'Haut-Médoc', 'haut-medoc', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Haut-M&eacute;doc</span></p>', '', '', '', 45, 'nl', 3, 'rayon/bordeaux/haut-medoc'),
(134, 'Barsac', 'barsac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Barsac</span></p>', '', '', '', 46, 'fr', 2, 'vin/bordeaux/barsac'),
(135, 'Barsac', 'barsac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Barsac</span></p>', '', '', '', 46, 'en', 1, 'rayon/bordeaux/barsac'),
(136, 'Barsac', 'barsac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Barsac</span></p>', '', '', '', 46, 'nl', 3, 'rayon/bordeaux/barsac'),
(137, 'Loupiac', 'loupiac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Loupiac</span></p>', '', '', '', 47, 'fr', 2, 'vin/bordeaux/loupiac'),
(138, 'Loupiac', 'loupiac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Loupiac</span></p>', '', '', '', 47, 'en', 1, 'rayon/bordeaux/loupiac'),
(139, 'Loupiac', 'loupiac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Loupiac</span></p>', '', '', '', 47, 'nl', 3, 'rayon/bordeaux/loupiac'),
(140, 'Vin de France', 'vin-de-france', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Vin de France</span></p>', '', '', '', 48, 'fr', 2, 'vin/bordeaux/vin-de-france'),
(141, 'Vin de France', 'vin-de-france', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Vin de France</span></p>', '', '', '', 48, 'en', 1, 'rayon/bordeaux/vin-de-france'),
(142, 'Vin de France', 'vin-de-france', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Vin de France</span></p>', '', '', '', 48, 'nl', 3, 'rayon/bordeaux/vin-de-france'),
(143, 'Canon-Fronsac', 'canon-fronsac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Canon-Fronsac</span></p>', '', '', '', 49, 'fr', 2, 'vin/bordeaux/canon-fronsac'),
(144, 'Canon-Fronsac', 'canon-fronsac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Canon-Fronsac</span></p>', '', '', '', 49, 'en', 1, 'rayon/bordeaux/canon-fronsac'),
(145, 'Canon-Fronsac', 'canon-fronsac', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Canon-Fronsac</span></p>', '', '', '', 49, 'nl', 3, 'rayon/bordeaux/canon-fronsac'),
(146, 'Blaye-Côtes de Bordeaux', 'blaye-cotes-de-bordeaux', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Blaye-C&ocirc;tes de Bordeaux</span></p>', '', '', '', 50, 'fr', 2, 'vin/bordeaux/blaye-cotes-de-bordeaux'),
(147, 'Blaye-Côtes de Bordeaux', 'blaye-cotes-de-bordeaux', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Blaye-C&ocirc;tes de Bordeaux</span></p>', '', '', '', 50, 'en', 1, 'rayon/bordeaux/blaye-cotes-de-bordeaux'),
(148, 'Blaye-Côtes de Bordeaux', 'blaye-cotes-de-bordeaux', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Blaye-C&ocirc;tes de Bordeaux</span></p>', '', '', '', 50, 'nl', 3, 'rayon/bordeaux/blaye-cotes-de-bordeaux'),
(149, 'Bordeaux-Côtes de Bourg', 'bordeaux-cotes-de-bourg', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Bordeaux-C&ocirc;tes de Bourg</span></p>', '', '', '', 51, 'fr', 2, 'vin/bordeaux/bordeaux-cotes-de-bourg'),
(150, 'Bordeaux-Côtes de Bourg', 'bordeaux-cotes-de-bourg', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Bordeaux-C&ocirc;tes de Bourg</span></p>', '', '', '', 51, 'en', 1, 'rayon/bordeaux/bordeaux-cotes-de-bourg'),
(151, 'Bordeaux-Côtes de Bourg', 'bordeaux-cotes-de-bourg', '<p><span style=\"color: #666666; font-family: OpenSans; font-size: 13px;\">Bordeaux-C&ocirc;tes de Bourg</span></p>', '', '', '', 51, 'nl', 3, 'rayon/bordeaux/bordeaux-cotes-de-bourg'),
(152, 'Lalande de Pomerol', 'lalande-de-pomerol', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Lalande de Pomerol</span></p>', '', '', '', 52, 'fr', 2, 'vin/bordeaux/lalande-de-pomerol'),
(153, 'Lalande de Pomerol', 'lalande-de-pomerol', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Lalande de Pomerol</span></p>', '', '', '', 52, 'en', 1, 'rayon/bordeaux/lalande-de-pomerol'),
(154, 'Lalande de Pomerol', 'lalande-de-pomerol', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Lalande de Pomerol</span></p>', '', '', '', 52, 'nl', 3, 'rayon/bordeaux/lalande-de-pomerol'),
(155, 'Moulis', 'moulis', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Vins de Moulis</span></p>', '', '', '', 53, 'fr', 2, 'vin/bordeaux/moulis'),
(156, 'Moulis', 'moulis', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Vins de Moulis</span></p>', '', '', '', 53, 'en', 1, 'rayon/bordeaux/moulis'),
(157, 'Moulis', 'moulis', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Vins de Moulis</span></p>', '', '', '', 53, 'nl', 3, 'rayon/bordeaux/moulis'),
(158, 'Fronsac', 'fronsac', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Fronsac</span></p>', '', '', '', 54, 'fr', 2, 'vin/bordeaux/fronsac'),
(159, 'Fronsac', 'fronsac', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Fronsac</span></p>', '', '', '', 54, 'en', 1, 'rayon/bordeaux/fronsac'),
(160, 'Fronsac', 'fronsac', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Fronsac</span></p>', '', '', '', 54, 'nl', 3, 'rayon/bordeaux/fronsac'),
(161, 'Listrac', 'listrac', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Listrac</span></p>', '', '', '', 55, 'fr', 2, 'vin/bordeaux/listrac'),
(162, 'Listrac', 'listrac', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Listrac</span></p>', '', '', '', 55, 'en', 1, 'rayon/bordeaux/listrac'),
(163, 'Listrac', 'listrac', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Listrac</span></p>', '', '', '', 55, 'nl', 3, 'rayon/bordeaux/listrac'),
(164, 'Montagne-Saint-Emilion', 'montagne-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Montagne-Saint-Emilion</span></p>', '', '', '', 56, 'fr', 2, 'vin/bordeaux/montagne-saint-emilion'),
(165, 'Montagne-Saint-Emilion', 'montagne-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Montagne-Saint-Emilion</span></p>', '', '', '', 56, 'en', 1, 'rayon/bordeaux/montagne-saint-emilion'),
(166, 'Montagne-Saint-Emilion', 'montagne-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Montagne-Saint-Emilion</span></p>', '', '', '', 56, 'nl', 3, 'rayon/bordeaux/montagne-saint-emilion'),
(167, 'Puisseguin-Saint-Emilion', 'puisseguin-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Puisseguin-Saint-Emilion</span></p>', '', '', '', 57, 'fr', 2, 'vin/bordeaux/puisseguin-saint-emilion'),
(168, 'Puisseguin-Saint-Emilion', 'puisseguin-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Puisseguin-Saint-Emilion</span></p>', '', '', '', 57, 'en', 1, 'rayon/bordeaux/puisseguin-saint-emilion'),
(169, 'Puisseguin-Saint-Emilion', 'puisseguin-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Puisseguin-Saint-Emilion</span></p>', '', '', '', 57, 'nl', 3, 'rayon/bordeaux/puisseguin-saint-emilion'),
(170, 'Saint-Georges-Saint-Emilion', 'saint-georges-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Saint-Georges-Saint-Emilion</span></p>', '', '', '', 58, 'fr', 2, 'vin/bordeaux/saint-georges-saint-emilion'),
(171, 'Saint-Georges-Saint-Emilion', 'saint-georges-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Saint-Georges-Saint-Emilion</span></p>', '', '', '', 58, 'en', 1, 'rayon/bordeaux/saint-georges-saint-emilion'),
(172, 'Saint-Georges-Saint-Emilion', 'saint-georges-saint-emilion', '<p><span style=\"color: #151515; font-family: Montserrat; font-size: 12.6px;\">Saint-Georges-Saint-Emilion</span></p>', '', '', '', 58, 'nl', 3, 'rayon/bordeaux/saint-georges-saint-emilion'),
(173, 'Alsace Gewurztraminer', 'alsace-gewurztraminer', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-gewurztraminer-11858-a-fr-eur-fr.html\">Alsace Gewurztraminer</a></li>\r\n</ul>', '', '', '', 59, 'fr', 2, 'vin/alsace/alsace-gewurztraminer'),
(174, 'Alsace Gewurztraminer', 'alsace-gewurztraminer', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-gewurztraminer-11858-a-fr-eur-fr.html\">Alsace Gewurztraminer</a></li>\r\n</ul>', '', '', '', 59, 'en', 1, 'rayon/alsace/alsace-gewurztraminer'),
(175, 'Alsace Gewurztraminer', 'alsace-gewurztraminer', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-gewurztraminer-11858-a-fr-eur-fr.html\">Alsace Gewurztraminer</a></li>\r\n</ul>', '', '', '', 59, 'nl', 3, 'rayon/alsace/alsace-gewurztraminer'),
(176, 'Alsace Grand Cru', 'alsace-grand-cru', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-grand-cru-11899-a-fr-eur-fr.html\">Alsace Grand Cru</a></li>\r\n</ul>', '', '', '', 60, 'fr', 2, 'vin/alsace/alsace-grand-cru'),
(177, 'Alsace Grand Cru', 'alsace-grand-cru', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-grand-cru-11899-a-fr-eur-fr.html\">Alsace Grand Cru</a></li>\r\n</ul>', '', '', '', 60, 'en', 1, 'rayon/alsace/alsace-grand-cru'),
(178, 'Alsace Grand Cru', 'alsace-grand-cru', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-grand-cru-11899-a-fr-eur-fr.html\">Alsace Grand Cru</a></li>\r\n</ul>', '', '', '', 60, 'nl', 3, 'rayon/alsace/alsace-grand-cru');
INSERT INTO `category_translations` (`id`, `name`, `slug`, `description`, `meta_title`, `meta_description`, `meta_keywords`, `category_id`, `locale`, `locale_id`, `url_path`) VALUES
(179, 'Alsace Pinot Blanc', 'alsace-pinot-blanc', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-blanc-12011-a-fr-eur-fr.html\">Alsace Pinot Blanc</a></li>\r\n</ul>', '', '', '', 61, 'fr', 2, 'vin/alsace/alsace-pinot-blanc'),
(180, 'Alsace Pinot Blanc', 'alsace-pinot-blanc', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-blanc-12011-a-fr-eur-fr.html\">Alsace Pinot Blanc</a></li>\r\n</ul>', '', '', '', 61, 'en', 1, 'rayon/alsace/alsace-pinot-blanc'),
(181, 'Alsace Pinot Blanc', 'alsace-pinot-blanc', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-blanc-12011-a-fr-eur-fr.html\">Alsace Pinot Blanc</a></li>\r\n</ul>', '', '', '', 61, 'nl', 3, 'rayon/alsace/alsace-pinot-blanc'),
(182, 'Alsace Pinot Gris', 'alsace-pinot-gris', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-gris-12012-a-fr-eur-fr.html\">Alsace Pinot Gris</a></li>\r\n</ul>', '', '', '', 62, 'fr', 2, 'vin/alsace/alsace-pinot-gris'),
(183, 'Alsace Pinot Gris', 'alsace-pinot-gris', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-gris-12012-a-fr-eur-fr.html\">Alsace Pinot Gris</a></li>\r\n</ul>', '', '', '', 62, 'en', 1, 'rayon/alsace/alsace-pinot-gris'),
(184, 'Alsace Pinot Gris', 'alsace-pinot-gris', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-gris-12012-a-fr-eur-fr.html\">Alsace Pinot Gris</a></li>\r\n</ul>', '', '', '', 62, 'nl', 3, 'rayon/alsace/alsace-pinot-gris'),
(185, 'Alsace Pinot noir', 'alsace-pinot-noir', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-noir-24190-a-fr-eur-fr.html\">Alsace Pinot noir</a></li>\r\n</ul>', '', '', '', 63, 'fr', 2, 'vin/alsace/alsace-pinot-noir'),
(186, 'Alsace Pinot noir', 'alsace-pinot-noir', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-noir-24190-a-fr-eur-fr.html\">Alsace Pinot noir</a></li>\r\n</ul>', '', '', '', 63, 'en', 1, 'rayon/alsace/alsace-pinot-noir'),
(187, 'Alsace Pinot noir', 'alsace-pinot-noir', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-pinot-noir-24190-a-fr-eur-fr.html\">Alsace Pinot noir</a></li>\r\n</ul>', '', '', '', 63, 'nl', 3, 'rayon/alsace/alsace-pinot-noir'),
(188, 'Alsace Riesling', 'alsace-riesling', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-riesling-12013-a-fr-eur-fr.html\">Alsace Riesling</a></li>\r\n</ul>', '', '', '', 64, 'fr', 2, 'vin/alsace/alsace-riesling'),
(189, 'Alsace Riesling', 'alsace-riesling', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-riesling-12013-a-fr-eur-fr.html\">Alsace Riesling</a></li>\r\n</ul>', '', '', '', 64, 'en', 1, 'rayon/alsace/alsace-riesling'),
(190, 'Alsace Riesling', 'alsace-riesling', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/alsace-riesling-12013-a-fr-eur-fr.html\">Alsace Riesling</a></li>\r\n</ul>', '', '', '', 64, 'nl', 3, 'rayon/alsace/alsace-riesling'),
(191, 'Riesling', 'riesling', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/riesling-23037-a-fr-eur-fr.html\">Riesling</a></li>\r\n</ul>', '', '', '', 65, 'fr', 2, 'vin/alsace/riesling'),
(192, 'Riesling', 'riesling', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/riesling-23037-a-fr-eur-fr.html\">Riesling</a></li>\r\n</ul>', '', '', '', 65, 'en', 1, 'rayon/alsace/riesling'),
(193, 'Riesling', 'riesling', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/riesling-23037-a-fr-eur-fr.html\">Riesling</a></li>\r\n</ul>', '', '', '', 65, 'nl', 3, 'rayon/alsace/riesling'),
(194, 'Clairette de Die', 'clairette-de-die', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Clairette de Die</span></p>', '', '', '', 66, 'fr', 2, 'effervescent/clairette-de-die'),
(195, 'Clairette de Die', 'clairette-de-die', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Clairette de Die</span></p>', '', '', '', 66, 'en', 1, 'effervescents/clairette-de-die'),
(196, 'Clairette de Die', 'clairette-de-die', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Clairette de Die</span></p>', '', '', '', 66, 'nl', 3, 'effervescents/clairette-de-die'),
(197, 'Crémants & Blanquettes', 'cremants-blanquettes', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants &amp; Blanquettes</span></p>', '', '', '', 67, 'fr', 2, 'effervescent/cremants-blanquettes'),
(198, 'Crémants & Blanquettes', 'cremants-blanquettes', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants &amp; Blanquettes</span></p>', '', '', '', 67, 'en', 1, 'effervescents/cremants-blanquettes'),
(199, 'Crémants & Blanquettes', 'cremants-blanquettes', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants &amp; Blanquettes</span></p>', '', '', '', 67, 'nl', 3, 'effervescents/cremants-blanquettes'),
(200, 'Blanquettes de Limoux', 'blanquettes-de-limoux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Blanquettes de Limoux</span></p>', '', '', '', 68, 'fr', 2, 'effervescent/cremants-blanquettes/blanquettes-de-limoux'),
(201, 'Blanquettes de Limoux', 'blanquettes-de-limoux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Blanquettes de Limoux</span></p>', '', '', '', 68, 'en', 1, 'effervescents/cremants-blanquettes/blanquettes-de-limoux'),
(202, 'Blanquettes de Limoux', 'blanquettes-de-limoux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Blanquettes de Limoux</span></p>', '', '', '', 68, 'nl', 3, 'effervescents/cremants-blanquettes/blanquettes-de-limoux'),
(203, 'Crémant d\'Alsace', 'cremant-dalsace', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/cremant-d-alsace-12005-a-fr-eur-fr.html\">Cr&eacute;mant d\'Alsace</a></li>\r\n</ul>', '', '', '', 69, 'fr', 2, 'effervescent/cremants-blanquettes/cremant-dalsace'),
(204, 'Crémant d\'Alsace', 'cremant-dalsace', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/cremant-d-alsace-12005-a-fr-eur-fr.html\">Cr&eacute;mant d\'Alsace</a></li>\r\n</ul>', '', '', '', 69, 'en', 1, 'effervescents/cremants-blanquettes/cremant-dalsace'),
(205, 'Crémant d\'Alsace', 'cremant-dalsace', '<ul class=\"col-sm-3\" style=\"box-sizing: border-box; margin-top: 0px; margin-bottom: 0px; position: relative; min-height: 1px; padding-left: 15px; padding-right: 15px; width: 285px; list-style: none; color: #5e5858; font-family: \'open sans\', sans-serif; background-color: #f5f5f5;\">\r\n<li style=\"box-sizing: border-box; margin: 5px 0px;\"><a style=\"box-sizing: border-box; background-color: transparent; color: #5e5858; text-decoration-line: none;\" href=\"https://www.wineandco.com/cremant-d-alsace-12005-a-fr-eur-fr.html\">Cr&eacute;mant d\'Alsace</a></li>\r\n</ul>', '', '', '', 69, 'nl', 3, 'effervescents/cremants-blanquettes/cremant-dalsace'),
(206, 'Crémants de Bourgogne', 'cremants-de-bourgogne', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Bourgogne</span></p>', '', '', '', 70, 'fr', 2, 'effervescent/cremants-blanquettes/cremants-de-bourgogne'),
(207, 'Crémants de Bourgogne', 'cremants-de-bourgogne', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Bourgogne</span></p>', '', '', '', 70, 'en', 1, 'effervescents/cremants-blanquettes/cremants-de-bourgogne'),
(208, 'Crémants de Bourgogne', 'cremants-de-bourgogne', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Bourgogne</span></p>', '', '', '', 70, 'nl', 3, 'effervescents/cremants-blanquettes/cremants-de-bourgogne'),
(209, 'Crémants de Limoux', 'cremants-de-limoux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Limoux</span></p>', '', '', '', 71, 'fr', 2, 'effervescent/cremants-blanquettes/cremants-de-limoux'),
(210, 'Crémants de Limoux', 'cremants-de-limoux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Limoux</span></p>', '', '', '', 71, 'en', 1, 'effervescents/cremants-blanquettes/cremants-de-limoux'),
(211, 'Crémants de Limoux', 'cremants-de-limoux', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Limoux</span></p>', '', '', '', 71, 'nl', 3, 'effervescents/cremants-blanquettes/cremants-de-limoux'),
(212, 'Crémants de Loire', 'cremants-de-loire', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Loire</span></p>', '', '', '', 72, 'fr', 2, 'effervescent/cremants-blanquettes/cremants-de-loire'),
(213, 'Crémants de Loire', 'cremants-de-loire', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Loire</span></p>', '', '', '', 72, 'en', 1, 'effervescents/cremants-blanquettes/cremants-de-loire'),
(214, 'Crémants de Loire', 'cremants-de-loire', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cr&eacute;mants de Loire</span></p>', '', '', '', 72, 'nl', 3, 'effervescents/cremants-blanquettes/cremants-de-loire'),
(215, 'Vouvray & Saumur', 'vouvray-saumur', '<h2 style=\"box-sizing: border-box; font-weight: 300; margin: 0px 0px 0.5em; font-size: 28px; line-height: 1.2; font-family: \'Roboto Condensed\', sans-serif; color: #333333; text-rendering: optimizelegibility; border-bottom: 1px solid #ffffff !important;\">Vouvray &amp; Saumur</h2>', '', '', '', 73, 'fr', 2, 'effervescent/cremants-blanquettes/vouvray-saumur'),
(216, 'Vouvray & Saumur', 'vouvray-saumur', '<h2 style=\"box-sizing: border-box; font-weight: 300; margin: 0px 0px 0.5em; font-size: 28px; line-height: 1.2; font-family: \'Roboto Condensed\', sans-serif; color: #333333; text-rendering: optimizelegibility; border-bottom: 1px solid #ffffff !important;\">Vouvray &amp; Saumur</h2>', '', '', '', 73, 'en', 1, 'effervescents/cremants-blanquettes/vouvray-saumur'),
(217, 'Vouvray & Saumur', 'vouvray-saumur', '<h2 style=\"box-sizing: border-box; font-weight: 300; margin: 0px 0px 0.5em; font-size: 28px; line-height: 1.2; font-family: \'Roboto Condensed\', sans-serif; color: #333333; text-rendering: optimizelegibility; border-bottom: 1px solid #ffffff !important;\">Vouvray &amp; Saumur</h2>', '', '', '', 73, 'nl', 3, 'effervescents/cremants-blanquettes/vouvray-saumur'),
(218, 'Effervescents du Monde', 'effervescents-du-monde', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Effervescents du Monde</span></p>', '', '', '', 74, 'fr', 2, 'effervescent/effervescents-du-monde'),
(219, 'Effervescents du Monde', 'effervescents-du-monde', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Effervescents du Monde</span></p>', '', '', '', 74, 'en', 1, 'effervescents/effervescents-du-monde'),
(220, 'Effervescents du Monde', 'effervescents-du-monde', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Effervescents du Monde</span></p>', '', '', '', 74, 'nl', 3, 'effervescents/effervescents-du-monde'),
(221, 'Cava', 'cava', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cava</span></p>', '', '', '', 75, 'fr', 2, 'effervescent/effervescents-du-monde/cava'),
(222, 'Cava', 'cava', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cava</span></p>', '', '', '', 75, 'en', 1, 'effervescents/effervescents-du-monde/cava'),
(223, 'Cava', 'cava', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Cava</span></p>', '', '', '', 75, 'nl', 3, 'effervescents/effervescents-du-monde/cava'),
(224, 'Lambrusco', 'lambrusco', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Lambrusco</span></p>', '', '', '', 76, 'fr', 2, 'effervescent/effervescents-du-monde/lambrusco'),
(225, 'Lambrusco', 'lambrusco', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Lambrusco</span></p>', '', '', '', 76, 'en', 1, 'effervescents/effervescents-du-monde/lambrusco'),
(226, 'Lambrusco', 'lambrusco', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Lambrusco</span></p>', '', '', '', 76, 'nl', 3, 'effervescents/effervescents-du-monde/lambrusco'),
(227, 'Prosecco', 'prosecco', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Prosecco</span></p>', '', '', '', 77, 'fr', 2, 'effervescent/effervescents-du-monde/prosecco'),
(228, 'Prosecco', 'prosecco', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Prosecco</span></p>', '', '', '', 77, 'en', 1, 'effervescents/effervescents-du-monde/prosecco'),
(229, 'Prosecco', 'prosecco', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Prosecco</span></p>', '', '', '', 77, 'nl', 3, 'effervescents/effervescents-du-monde/prosecco'),
(230, 'Spumante', 'spumante', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Spumante</span></p>', '', '', '', 78, 'fr', 2, 'effervescent/effervescents-du-monde/spumante'),
(231, 'Spumante', 'spumante', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Spumante</span></p>', '', '', '', 78, 'en', 1, 'effervescents/effervescents-du-monde/spumante'),
(232, 'Spumante', 'spumante', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Spumante</span></p>', '', '', '', 78, 'nl', 3, 'effervescents/effervescents-du-monde/spumante'),
(233, 'Autres Effervescents', 'autres-effervescents', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Autres Effervescents</span></p>', '', '', '', 79, 'fr', 2, 'effervescent/effervescents-du-monde/autres-effervescents'),
(234, 'Autres Effervescents', 'autres-effervescents', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Autres Effervescents</span></p>', '', '', '', 79, 'en', 1, 'effervescents/effervescents-du-monde/autres-effervescents'),
(235, 'Autres Effervescents', 'autres-effervescents', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Autres Effervescents</span></p>', '', '', '', 79, 'nl', 3, 'effervescents/effervescents-du-monde/autres-effervescents'),
(236, 'Effervescents sans alcool', 'effervescents-sans-alcool', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Effervescents sans alcool</span></p>', '', '', '', 80, 'fr', 2, 'effervescent/effervescents-du-monde/effervescents-sans-alcool'),
(237, 'Effervescents sans alcool', 'effervescents-sans-alcool', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Effervescents sans alcool</span></p>', '', '', '', 80, 'en', 1, 'effervescents/effervescents-du-monde/effervescents-sans-alcool'),
(238, 'Effervescents sans alcool', 'effervescents-sans-alcool', '<p><span style=\"color: #222222; font-family: Consolas, \'Lucida Console\', \'Courier New\', monospace; font-size: 12px; white-space: pre-wrap;\">Effervescents sans alcool</span></p>', '', '', '', 80, 'nl', 3, 'effervescents/effervescents-du-monde/effervescents-sans-alcool'),
(239, 'Bruts', 'bruts', '<p>Bruts</p>', '', '', '', 81, 'fr', 2, 'champagne/bruts'),
(240, 'Bruts', 'bruts', '<p>Bruts</p>', '', '', '', 81, 'en', 1, 'champagne/bruts'),
(241, 'Bruts', 'bruts', '<p>Bruts</p>', '', '', '', 81, 'nl', 3, 'champagne/bruts'),
(242, 'Blanc de Blancs', 'blanc-de-blancs', '<p>Blanc de Blancs</p>', '', '', '', 82, 'fr', 2, 'champagne/blanc-de-blancs'),
(243, 'Blanc de Blancs', 'blanc-de-blancs', '<p>Blanc de Blancs</p>', '', '', '', 82, 'en', 1, 'champagne/blanc-de-blancs'),
(244, 'Blanc de Blancs', 'blanc-de-blancs', '<p>Blanc de Blancs</p>', '', '', '', 82, 'nl', 3, 'champagne/blanc-de-blancs'),
(245, 'Blanc de Noirs', 'blanc-de-noirs', '<p>Blanc de Noirs</p>', '', '', '', 83, 'fr', 2, 'champagne/blanc-de-noirs'),
(246, 'Blanc de Noirs', 'blanc-de-noirs', '<p>Blanc de Noirs</p>', '', '', '', 83, 'en', 1, 'champagne/blanc-de-noirs'),
(247, 'Blanc de Noirs', 'blanc-de-noirs', '<p>Blanc de Noirs</p>', '', '', '', 83, 'nl', 3, 'champagne/blanc-de-noirs'),
(248, 'Demi-Secs', 'demi-secs', '<p>Demi-Secs</p>', '', '', '', 84, 'fr', 2, 'champagne/demi-secs'),
(249, 'Demi-Secs', 'demi-secs', '<p>Demi-Secs</p>', '', '', '', 84, 'en', 1, 'champagne/demi-secs'),
(250, 'Demi-Secs', 'demi-secs', '<p>Demi-Secs</p>', '', '', '', 84, 'nl', 3, 'champagne/demi-secs'),
(251, 'Extra-Brut', 'extra-brut', '<p>Extra-Brut</p>', '', '', '', 85, 'fr', 2, 'champagne/extra-brut'),
(252, 'Extra-Brut', 'extra-brut', '<p>Extra-Brut</p>', '', '', '', 85, 'en', 1, 'champagne/extra-brut'),
(253, 'Extra-Brut', 'extra-brut', '<p>Extra-Brut</p>', '', '', '', 85, 'nl', 3, 'champagne/extra-brut'),
(254, 'Millésimés', 'millesimes', '<p>Mill&eacute;sim&eacute;s</p>', '', '', '', 86, 'fr', 2, 'champagne/millesimes'),
(255, 'Millésimés', 'millesimes', '<p>Mill&eacute;sim&eacute;s</p>', '', '', '', 86, 'en', 1, 'champagne/millesimes'),
(256, 'Millésimés', 'millesimes', '<p>Mill&eacute;sim&eacute;s</p>', '', '', '', 86, 'nl', 3, 'champagne/millesimes'),
(257, 'Rosés', 'roses', '<p>Ros&eacute;s</p>', '', '', '', 87, 'fr', 2, 'champagne/roses'),
(258, 'Rosés', 'roses', '<p>Ros&eacute;s</p>', '', '', '', 87, 'en', 1, 'champagne/roses'),
(259, 'Rosés', 'roses', '<p>Ros&eacute;s</p>', '', '', '', 87, 'nl', 3, 'champagne/roses');

--
-- Déclencheurs `category_translations`
--
DROP TRIGGER IF EXISTS `trig_category_translations_insert`;
DELIMITER $$
CREATE TRIGGER `trig_category_translations_insert` BEFORE INSERT ON `category_translations` FOR EACH ROW BEGIN
                            DECLARE parentUrlPath varchar(255);
            DECLARE urlPath varchar(255);

            IF NOT EXISTS (
                SELECT id
                FROM categories
                WHERE
                    id = NEW.category_id
                    AND parent_id IS NULL
            )
            THEN

                SELECT
                    GROUP_CONCAT(parent_translations.slug SEPARATOR '/') INTO parentUrlPath
                FROM
                    categories AS node,
                    categories AS parent
                    JOIN category_translations AS parent_translations ON parent.id = parent_translations.category_id
                WHERE
                    node._lft >= parent._lft
                    AND node._rgt <= parent._rgt
                    AND node.id = (SELECT parent_id FROM categories WHERE id = NEW.category_id)
                    AND node.parent_id IS NOT NULL
                    AND parent.parent_id IS NOT NULL
                    AND parent_translations.locale = NEW.locale
                GROUP BY
                    node.id;

                IF parentUrlPath IS NULL
                THEN
                    SET urlPath = NEW.slug;
                ELSE
                    SET urlPath = concat(parentUrlPath, '/', NEW.slug);
                END IF;

                SET NEW.url_path = urlPath;

            END IF;
            END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `trig_category_translations_update`;
DELIMITER $$
CREATE TRIGGER `trig_category_translations_update` BEFORE UPDATE ON `category_translations` FOR EACH ROW BEGIN
                            DECLARE parentUrlPath varchar(255);
            DECLARE urlPath varchar(255);

            IF NOT EXISTS (
                SELECT id
                FROM categories
                WHERE
                    id = NEW.category_id
                    AND parent_id IS NULL
            )
            THEN

                SELECT
                    GROUP_CONCAT(parent_translations.slug SEPARATOR '/') INTO parentUrlPath
                FROM
                    categories AS node,
                    categories AS parent
                    JOIN category_translations AS parent_translations ON parent.id = parent_translations.category_id
                WHERE
                    node._lft >= parent._lft
                    AND node._rgt <= parent._rgt
                    AND node.id = (SELECT parent_id FROM categories WHERE id = NEW.category_id)
                    AND node.parent_id IS NOT NULL
                    AND parent.parent_id IS NOT NULL
                    AND parent_translations.locale = NEW.locale
                GROUP BY
                    node.id;

                IF parentUrlPath IS NULL
                THEN
                    SET urlPath = NEW.slug;
                ELSE
                    SET urlPath = concat(parentUrlPath, '/', NEW.slug);
                END IF;

                SET NEW.url_path = urlPath;

            END IF;
            END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `channels`
--

DROP TABLE IF EXISTS `channels`;
CREATE TABLE IF NOT EXISTS `channels` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `timezone` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `theme` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hostname` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `favicon` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `home_page_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `footer_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `default_locale_id` int UNSIGNED NOT NULL,
  `base_currency_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `root_category_id` int UNSIGNED DEFAULT NULL,
  `home_seo` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `channels_default_locale_id_foreign` (`default_locale_id`),
  KEY `channels_base_currency_id_foreign` (`base_currency_id`),
  KEY `channels_root_category_id_foreign` (`root_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `channels`
--

INSERT INTO `channels` (`id`, `code`, `name`, `description`, `timezone`, `theme`, `hostname`, `logo`, `favicon`, `home_page_content`, `footer_content`, `default_locale_id`, `base_currency_id`, `created_at`, `updated_at`, `root_category_id`, `home_seo`) VALUES
(1, 'winebtob', 'Winebtob', '', NULL, 'velocity', 'https://winebtob.com/', NULL, NULL, '<p>@include(\"shop::home.slider\") @include(\"shop::home.featured-products\") @include(\"shop::home.new-products\")</p>\r\n<div class=\"banner-container\">\r\n<div class=\"left-banner\"><img src=\"https://s3-ap-southeast-1.amazonaws.com/cdn.uvdesk.com/website/1/201902045c581f9494b8a1.png\" /></div>\r\n<div class=\"right-banner\"><img src=\"https://s3-ap-southeast-1.amazonaws.com/cdn.uvdesk.com/website/1/201902045c581fb045cf02.png\" /> <img src=\"https://s3-ap-southeast-1.amazonaws.com/cdn.uvdesk.com/website/1/201902045c581fc352d803.png\" /></div>\r\n</div>', '<div class=\"list-container\"><span class=\"list-heading\">Quick Links</span>\r\n<ul class=\"list-group\">\r\n<li><a href=\"@php echo route(\'shop.cms.page\', \'about-us\') @endphp\">About Us</a></li>\r\n<li><a href=\"@php echo route(\'shop.cms.page\', \'return-policy\') @endphp\">Return Policy</a></li>\r\n<li><a href=\"@php echo route(\'shop.cms.page\', \'refund-policy\') @endphp\">Refund Policy</a></li>\r\n<li><a href=\"@php echo route(\'shop.cms.page\', \'terms-conditions\') @endphp\">Terms and conditions</a></li>\r\n<li><a href=\"@php echo route(\'shop.cms.page\', \'terms-of-use\') @endphp\">Terms of Use</a></li>\r\n<li><a href=\"@php echo route(\'shop.cms.page\', \'contact-us\') @endphp\">Contact Us</a></li>\r\n</ul>\r\n</div>\r\n<div class=\"list-container\"><span class=\"list-heading\">Connect With Us</span>\r\n<ul class=\"list-group\">\r\n<li><a href=\"#\"><span class=\"icon icon-facebook\"></span>Facebook </a></li>\r\n<li><a href=\"#\"><span class=\"icon icon-twitter\"></span> Twitter </a></li>\r\n<li><a href=\"#\"><span class=\"icon icon-instagram\"></span> Instagram </a></li>\r\n<li><a href=\"#\"> <span class=\"icon icon-google-plus\"></span>Google+ </a></li>\r\n<li><a href=\"#\"> <span class=\"icon icon-linkedin\"></span>LinkedIn </a></li>\r\n</ul>\r\n</div>', 2, 2, NULL, '2020-09-22 07:16:06', 1, '{\"meta_title\": \"Wine B to B\", \"meta_keywords\": \"wine btob\", \"meta_description\": \"Wine btob\"}');

-- --------------------------------------------------------

--
-- Structure de la table `channel_currencies`
--

DROP TABLE IF EXISTS `channel_currencies`;
CREATE TABLE IF NOT EXISTS `channel_currencies` (
  `channel_id` int UNSIGNED NOT NULL,
  `currency_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`channel_id`,`currency_id`),
  KEY `channel_currencies_currency_id_foreign` (`currency_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `channel_currencies`
--

INSERT INTO `channel_currencies` (`channel_id`, `currency_id`) VALUES
(1, 2);

-- --------------------------------------------------------

--
-- Structure de la table `channel_inventory_sources`
--

DROP TABLE IF EXISTS `channel_inventory_sources`;
CREATE TABLE IF NOT EXISTS `channel_inventory_sources` (
  `channel_id` int UNSIGNED NOT NULL,
  `inventory_source_id` int UNSIGNED NOT NULL,
  UNIQUE KEY `channel_inventory_sources_channel_id_inventory_source_id_unique` (`channel_id`,`inventory_source_id`),
  KEY `channel_inventory_sources_inventory_source_id_foreign` (`inventory_source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `channel_inventory_sources`
--

INSERT INTO `channel_inventory_sources` (`channel_id`, `inventory_source_id`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Structure de la table `channel_locales`
--

DROP TABLE IF EXISTS `channel_locales`;
CREATE TABLE IF NOT EXISTS `channel_locales` (
  `channel_id` int UNSIGNED NOT NULL,
  `locale_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`channel_id`,`locale_id`),
  KEY `channel_locales_locale_id_foreign` (`locale_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `channel_locales`
--

INSERT INTO `channel_locales` (`channel_id`, `locale_id`) VALUES
(1, 2);

-- --------------------------------------------------------

--
-- Structure de la table `cms_pages`
--

DROP TABLE IF EXISTS `cms_pages`;
CREATE TABLE IF NOT EXISTS `cms_pages` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `layout` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `cms_pages`
--

INSERT INTO `cms_pages` (`id`, `layout`, `created_at`, `updated_at`) VALUES
(1, NULL, '2020-07-13 09:51:42', '2020-07-13 09:51:42'),
(2, NULL, '2020-07-13 09:51:42', '2020-07-13 09:51:42'),
(3, NULL, '2020-07-13 09:51:42', '2020-07-13 09:51:42'),
(4, NULL, '2020-07-13 09:51:42', '2020-07-13 09:51:42'),
(5, NULL, '2020-07-13 09:51:42', '2020-07-13 09:51:42'),
(6, NULL, '2020-07-13 09:51:42', '2020-07-13 09:51:42');

-- --------------------------------------------------------

--
-- Structure de la table `cms_page_channels`
--

DROP TABLE IF EXISTS `cms_page_channels`;
CREATE TABLE IF NOT EXISTS `cms_page_channels` (
  `cms_page_id` int UNSIGNED NOT NULL,
  `channel_id` int UNSIGNED NOT NULL,
  UNIQUE KEY `cms_page_channels_cms_page_id_channel_id_unique` (`cms_page_id`,`channel_id`),
  KEY `cms_page_channels_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `cms_page_translations`
--

DROP TABLE IF EXISTS `cms_page_translations`;
CREATE TABLE IF NOT EXISTS `cms_page_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `page_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `url_key` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `html_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_keywords` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cms_page_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cms_page_translations_cms_page_id_url_key_locale_unique` (`cms_page_id`,`url_key`,`locale`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `cms_page_translations`
--

INSERT INTO `cms_page_translations` (`id`, `page_title`, `url_key`, `html_content`, `meta_title`, `meta_description`, `meta_keywords`, `locale`, `cms_page_id`) VALUES
(25, 'About Us', 'about-us', '<div class=\"static-container\"><div class=\"mb-5\">About us page content</div></div>', 'about us', '', 'aboutus', 'en', 1),
(26, 'Return Policy', 'return-policy', '<div class=\"static-container\"><div class=\"mb-5\">Return policy page content</div></div>', 'return policy', '', 'return, policy', 'en', 2),
(27, 'Refund Policy', 'refund-policy', '<div class=\"static-container\"><div class=\"mb-5\">Refund policy page content</div></div>', 'Refund policy', '', 'refund, policy', 'en', 3),
(28, 'Terms & Conditions', 'terms-conditions', '<div class=\"static-container\"><div class=\"mb-5\">Terms & conditions page content</div></div>', 'Terms & Conditions', '', 'term, conditions', 'en', 4),
(29, 'Terms of use', 'terms-of-use', '<div class=\"static-container\"><div class=\"mb-5\">Terms of use page content</div></div>', 'Terms of use', '', 'term, use', 'en', 5),
(30, 'Contact Us', 'contact-us', '<div class=\"static-container\"><div class=\"mb-5\">Contact us page content</div></div>', 'Contact Us', '', 'contact, us', 'en', 6);

-- --------------------------------------------------------

--
-- Structure de la table `core_config`
--

DROP TABLE IF EXISTS `core_config`;
CREATE TABLE IF NOT EXISTS `core_config` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `locale_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `core_config_channel_id_foreign` (`channel_code`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `core_config`
--

INSERT INTO `core_config` (`id`, `code`, `value`, `channel_code`, `locale_code`, `created_at`, `updated_at`) VALUES
(1, 'catalog.products.guest-checkout.allow-guest-checkout', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(2, 'emails.general.notifications.emails.general.notifications.verification', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(3, 'emails.general.notifications.emails.general.notifications.registration', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(4, 'emails.general.notifications.emails.general.notifications.customer', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(5, 'emails.general.notifications.emails.general.notifications.new-order', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(6, 'emails.general.notifications.emails.general.notifications.new-admin', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(7, 'emails.general.notifications.emails.general.notifications.new-invoice', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(8, 'emails.general.notifications.emails.general.notifications.new-refund', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(9, 'emails.general.notifications.emails.general.notifications.new-shipment', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(10, 'emails.general.notifications.emails.general.notifications.new-inventory-source', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(11, 'emails.general.notifications.emails.general.notifications.cancel-order', '1', NULL, NULL, '2020-07-13 09:51:41', '2020-07-13 09:51:41'),
(12, 'b2b_marketplace.settings.general.supplier_approval_required', '1', NULL, NULL, NULL, '2020-09-22 07:08:44'),
(13, 'b2b_marketplace.settings.general.product_approval_required', '1', NULL, NULL, NULL, '2020-09-22 07:08:44'),
(14, 'b2b_marketplace.settings.general.commission_per_unit', '10', 'default', NULL, NULL, '2020-09-22 07:08:44'),
(15, 'b2b_marketplace.settings.general.can_create_invoice', '1', NULL, NULL, NULL, '2020-09-22 07:08:44'),
(16, 'b2b_marketplace.settings.general.can_create_shipment', '1', NULL, NULL, NULL, '2020-09-22 07:08:44'),
(17, 'b2b_marketplace.settings.landing_page.page_title', 'There Is No Finish Line', 'default', 'en', NULL, NULL),
(18, 'b2b_marketplace.settings.landing_page.show_banner', '1', NULL, NULL, NULL, NULL),
(19, 'b2b_marketplace.settings.landing_page.banner_content', 'Shake hand with the most reported company known for eCommerce and the marketplace. We reached around all the corners of the world. We serve the customer with our best service experiences.', 'default', 'en', NULL, NULL),
(20, 'b2b_marketplace.settings.landing_page.show_features', '1', NULL, NULL, NULL, NULL),
(21, 'b2b_marketplace.settings.landing_page.feature_heading', 'Attracting Features', 'default', 'en', NULL, NULL),
(22, 'b2b_marketplace.settings.landing_page.feature_info', 'Want to start an online business? Before any decision, please check our unbeatable features.', 'default', 'en', NULL, NULL),
(23, 'b2b_marketplace.settings.landing_page.feature_icon_label_1', 'Generate Revenue', 'default', 'en', NULL, NULL),
(24, 'b2b_marketplace.settings.landing_page.feature_icon_label_2', 'Sell Unlimited Products', 'default', 'en', NULL, NULL),
(25, 'b2b_marketplace.settings.landing_page.feature_icon_label_3', 'Offer for Suppliers', 'default', 'en', NULL, NULL),
(26, 'b2b_marketplace.settings.landing_page.feature_icon_label_4', 'Supplier Dashboard', 'default', 'en', NULL, NULL),
(27, 'b2b_marketplace.settings.landing_page.feature_icon_label_5', 'Supplier Order Management And Quick Order', 'default', 'en', NULL, NULL),
(28, 'b2b_marketplace.settings.landing_page.feature_icon_label_6', 'Supplier Branding', 'default', 'en', NULL, NULL),
(29, 'b2b_marketplace.settings.landing_page.feature_icon_label_7', 'Connect with Social', 'default', 'en', NULL, NULL),
(30, 'b2b_marketplace.settings.landing_page.feature_icon_label_8', 'Buyer Supplier Communication', 'default', 'en', NULL, NULL),
(31, 'b2b_marketplace.settings.landing_page.feature_icon_label_9', 'Request For Quote', 'default', 'en', NULL, NULL),
(32, 'b2b_marketplace.settings.landing_page.show_popular_suppliers', '1', NULL, NULL, NULL, NULL),
(33, 'b2b_marketplace.settings.landing_page.open_shop_button_label', 'Open Shop Now', 'default', 'en', NULL, NULL),
(34, 'b2b_marketplace.settings.landing_page.show_open_shop_block', '1', NULL, NULL, NULL, NULL),
(35, 'b2b_marketplace.settings.landing_page.open_shop_info', 'Open your online shop with us and get explore the new world with more then millions of shoppers.', 'default', 'en', NULL, NULL),
(36, 'b2b_marketplace.settings.landing_page.banner', 'configuration/9OGztMGb6nKUCBbF58xpNA1EShskKjoj9iUvJCrD.png', 'default', NULL, NULL, NULL),
(37, 'b2b_marketplace.settings.landing_page.feature_icon_1', 'configuration/3npLBJCCEnvjtescuelWsENPEm0FzhvElzmFRWIe.png', 'default', NULL, NULL, NULL),
(38, 'b2b_marketplace.settings.landing_page.feature_icon_2', 'configuration/sGtL2WxTxjFypyRMioRth0y4FRJUW6pZEYKfQXq2.png', 'default', NULL, NULL, NULL),
(39, 'b2b_marketplace.settings.landing_page.feature_icon_3', 'configuration/kZZ5OSziGW3aQNVGkq4r4GL2VNTsQhVWLt62C0wb.png', 'default', NULL, NULL, NULL),
(40, 'b2b_marketplace.settings.landing_page.feature_icon_4', 'configuration/cN1NGisKLyVpsn1AldCEQg8ZZCJtSbbd5zTjZGwX.png', 'default', NULL, NULL, NULL),
(41, 'b2b_marketplace.settings.landing_page.feature_icon_5', 'configuration/eSHFNPfIWrw7gLffadeR4FgOgBMeQtxWWxfmB45o.png', 'default', NULL, NULL, NULL),
(42, 'b2b_marketplace.settings.landing_page.feature_icon_6', 'configuration/9Iggsyrd6OElGvYHg27LKfgvgLHx3hBKTXgESxYC.png', 'default', NULL, NULL, NULL),
(43, 'b2b_marketplace.settings.landing_page.feature_icon_7', 'configuration/YvJHOSJLldKpgi0MrgDNy0ookuAyXbYuAtQQI9am.png', 'default', NULL, NULL, NULL),
(44, 'b2b_marketplace.settings.landing_page.feature_icon_8', 'configuration/i7dgjt2Hw5xhUdmploHWMoV0aNml3W4GjEAyZm5e.png', 'default', NULL, NULL, NULL),
(45, 'b2b_marketplace.settings.landing_page.feature_icon_9', 'configuration/Icon-RFQ-SELL.svg', 'default', NULL, NULL, NULL),
(46, 'b2b_marketplace.settings.landing_page.about_b2bmarketplace', '<div style=\"width: 100%; display: inline-block; padding-bottom: 30px;\"><h1 style=\"text-align: center; font-size: 24px; color: rgb(36, 36, 36); margin-bottom: 40px;\">Why to sell with us</h1><div style=\"width: 28%; float: left; padding-right: 20px;\"><img src=\"http://magento2.webkul.com/marketplace/pub/media/wysiwyg/landingpage/img-customize-seller-profile.png\" alt=\"\" style=\"width: 100%;\"></div> <div style=\"width: 70%; float: left; text-align: justify;\"><h2 style=\"color: rgb(99, 99, 99); margin: 0px; font-size: 22px;\">Easily Customize your supplier profile</h2> <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p> <p>&nbsp;</p> <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p></div></div> <div style=\"width: 100%; display: inline-block; padding-bottom: 30px;\"><div style=\"width: 70%; float: left; padding-right: 20px; text-align: justify;\"><h2 style=\"color: rgb(99, 99, 99); margin: 0px; font-size: 22px;\">Add Unlimited Products</h2> <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p> <p>&nbsp;</p> <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p></div> <div style=\"width: 28%; float: left;\"><img src=\"http://magento2.webkul.com/marketplace/pub/media/wysiwyg/landingpage/img-add-unlimited-products.png\" alt=\"\" style=\"width: 100%;\"></div></div> <div style=\"width: 100%; display: inline-block; padding-bottom: 30px;\"><div style=\"width: 28%; float: left; padding-right: 20px;\"><img src=\"http://magento2.webkul.com/marketplace/pub/media/wysiwyg/landingpage/img-connect-to-your-social-profile.png\" alt=\"\" style=\"width: 100%;\"></div> <div style=\"width: 70%; float: left;text-align: justify;\"><h2 style=\"color: rgb(99, 99, 99); margin: 0px; font-size: 22px;\">Connect to your social profile</h2> <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p> <p>&nbsp;</p> <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p></div></div> <div style=\"width: 100%; display: inline-block; padding-bottom: 30px;\"><div style=\"width: 70%; float: left; padding-right: 20px; text-align: justify;\"><h3 style=\"color: rgb(99, 99, 99); margin: 0px;\">Buyer can ask you a question</h3> <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p> <p>&nbsp;</p> <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p> <p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p></div> <div style=\"width: 28%; float: left;\"><img src=\"http://magento2.webkul.com/marketplace/pub/media/wysiwyg/landingpage/img-buyers-can-ask-a-question.png\" alt=\"\" style=\"width: 100%;\"></div></div>', 'default', 'en', NULL, NULL),
(47, 'b2b_marketplace.settings.general.can_cancel_order', '1', NULL, NULL, '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(48, 'b2b_marketplace.settings.general.chat_notification', '1', 'default', 'fr', '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(49, 'b2b_marketplace.settings.supplier_profile_page.policies_enable', '1', NULL, NULL, '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(50, 'b2b_marketplace.settings.supplier_profile_page.rewrite_shop_url', '1', NULL, NULL, '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(51, 'b2b_marketplace.settings.email.verification', '1', 'default', 'fr', '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(52, 'b2b_marketplace.settings.landing_page.page_title', '', 'default', 'fr', '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(53, 'b2b_marketplace.settings.landing_page.banner_content', '', 'default', 'fr', '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(54, 'b2b_marketplace.settings.landing_page.feature_heading', '', 'default', 'fr', '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(55, 'b2b_marketplace.settings.landing_page.feature_info', '', 'default', 'fr', '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(56, 'b2b_marketplace.settings.landing_page.feature_icon_label_1', '', 'default', 'fr', '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(57, 'b2b_marketplace.settings.landing_page.feature_icon_label_2', '', 'default', 'fr', '2020-09-22 07:08:44', '2020-09-22 07:08:44'),
(58, 'b2b_marketplace.settings.landing_page.feature_icon_label_3', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(59, 'b2b_marketplace.settings.landing_page.feature_icon_label_4', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(60, 'b2b_marketplace.settings.landing_page.feature_icon_label_5', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(61, 'b2b_marketplace.settings.landing_page.feature_icon_label_6', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(62, 'b2b_marketplace.settings.landing_page.feature_icon_label_7', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(63, 'b2b_marketplace.settings.landing_page.feature_icon_label_8', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(64, 'b2b_marketplace.settings.landing_page.feature_icon_label_9', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(65, 'b2b_marketplace.settings.landing_page.show_popular_sellers', '0', NULL, NULL, '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(66, 'b2b_marketplace.settings.landing_page.open_shop_button_label', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(67, 'b2b_marketplace.settings.landing_page.about_b2bmarketplace', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(68, 'b2b_marketplace.settings.landing_page.open_shop_info', '', 'default', 'fr', '2020-09-22 07:08:45', '2020-09-22 07:08:45'),
(69, 'customer.settings.address.street_lines', '1', 'default', NULL, '2020-09-22 07:10:27', '2020-09-22 07:10:27'),
(70, 'customer.settings.newsletter.subscription', '1', NULL, NULL, '2020-09-22 07:10:27', '2020-09-22 07:10:27'),
(71, 'customer.settings.email.verification', '0', NULL, NULL, '2020-09-22 07:10:27', '2020-09-22 07:10:27'),
(72, 'customer.settings.documents.size', '', NULL, NULL, '2020-09-22 07:10:27', '2020-09-22 07:10:27'),
(73, 'customer.settings.documents.allowed_extensions', '', NULL, NULL, '2020-09-22 07:10:27', '2020-09-22 07:10:27'),
(74, 'sales.shipping.origin.country', 'FR', 'default', 'fr', '2020-09-22 07:11:43', '2020-09-22 07:11:43'),
(75, 'sales.shipping.origin.state', '92', 'default', 'fr', '2020-09-22 07:11:43', '2020-09-22 07:11:43'),
(76, 'sales.shipping.origin.address1', '121 rue d\'aguesseau', 'default', NULL, '2020-09-22 07:11:43', '2020-09-22 07:11:43'),
(77, 'sales.shipping.origin.zipcode', '92100', 'default', NULL, '2020-09-22 07:11:43', '2020-09-22 07:11:43'),
(78, 'sales.shipping.origin.city', 'BOULOGNE BILLANCOURT', 'default', NULL, '2020-09-22 07:11:43', '2020-09-22 07:11:43'),
(79, 'sales.carriers.free.title', 'Frais de port offert', NULL, 'fr', '2020-09-22 07:12:35', '2020-09-22 07:12:35'),
(80, 'sales.carriers.free.description', 'Frais de port offert', NULL, 'fr', '2020-09-22 07:12:35', '2020-09-22 07:12:35'),
(81, 'sales.carriers.free.active', '1', NULL, 'fr', '2020-09-22 07:12:35', '2020-09-22 07:12:35'),
(82, 'sales.carriers.flatrate.title', 'Flat Rate', 'default', 'fr', '2020-09-22 07:12:35', '2020-09-22 07:12:35'),
(83, 'sales.carriers.flatrate.description', 'Flat Rate Shipping', 'default', NULL, '2020-09-22 07:12:35', '2020-09-22 07:12:35'),
(84, 'sales.carriers.flatrate.default_rate', '10', 'default', NULL, '2020-09-22 07:12:35', '2020-09-22 07:12:35'),
(85, 'sales.carriers.flatrate.type', 'per_order', NULL, NULL, '2020-09-22 07:12:35', '2020-09-22 07:12:35'),
(86, 'sales.carriers.flatrate.active', '1', NULL, 'fr', '2020-09-22 07:12:35', '2020-09-22 07:12:35'),
(87, 'sales.paymentmethods.cashondelivery.title', 'Paiement sur facture', NULL, 'fr', '2020-09-22 07:13:59', '2020-09-22 07:13:59'),
(88, 'sales.paymentmethods.cashondelivery.description', 'Paiement sur facture', NULL, 'fr', '2020-09-22 07:13:59', '2020-09-22 07:13:59'),
(89, 'sales.paymentmethods.cashondelivery.active', '1', NULL, 'fr', '2020-09-22 07:13:59', '2020-09-22 07:13:59'),
(90, 'sales.paymentmethods.cashondelivery.sort', '1', NULL, NULL, '2020-09-22 07:13:59', '2020-09-22 07:13:59'),
(91, 'sales.paymentmethods.moneytransfer.title', 'Virement bancaire', NULL, 'fr', '2020-09-22 07:13:59', '2020-09-22 07:13:59'),
(92, 'sales.paymentmethods.moneytransfer.description', 'Virement bancaire', NULL, 'fr', '2020-09-22 07:13:59', '2020-09-22 07:13:59'),
(93, 'sales.paymentmethods.moneytransfer.active', '1', NULL, 'fr', '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(94, 'sales.paymentmethods.moneytransfer.sort', '2', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(95, 'sales.paymentmethods.paypal_standard.title', 'Paypal Standard', NULL, 'fr', '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(96, 'sales.paymentmethods.paypal_standard.description', 'Paypal Standard', NULL, 'fr', '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(97, 'sales.paymentmethods.paypal_standard.business_account', 'test@webkul.com', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(98, 'sales.paymentmethods.paypal_standard.active', '0', NULL, 'fr', '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(99, 'sales.paymentmethods.paypal_standard.sandbox', '0', NULL, 'fr', '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(100, 'sales.paymentmethods.paypal_standard.sort', '3', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(101, 'sales.paymentmethods.stripe.active', '1', NULL, 'fr', '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(102, 'sales.paymentmethods.stripe.title', 'B2BStripe', 'default', 'fr', '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(103, 'sales.paymentmethods.stripe.description', 'Stripe Payments', 'default', 'fr', '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(104, 'sales.paymentmethods.stripe.debug', '1', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(105, 'sales.paymentmethods.stripe.application_fee', 'seller', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(106, 'sales.paymentmethods.stripe.api_key', '', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(107, 'sales.paymentmethods.stripe.api_publishable_key', '', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(108, 'sales.paymentmethods.stripe.client_id', '', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(109, 'sales.paymentmethods.stripe.api_test_key', '', NULL, NULL, '2020-09-22 07:14:00', '2020-09-22 07:14:00'),
(110, 'sales.paymentmethods.stripe.api_test_publishable_key', '', NULL, NULL, '2020-09-22 07:14:01', '2020-09-22 07:14:01'),
(111, 'sales.paymentmethods.stripe.sort', '1', NULL, NULL, '2020-09-22 07:14:01', '2020-09-22 07:14:01'),
(112, 'general.general.locale_options.weight_unit', 'kgs', 'default', NULL, '2020-09-22 07:24:49', '2020-09-22 07:24:49'),
(113, 'general.general.email_settings.sender_name', 'Wine BtoB', 'default', NULL, '2020-09-22 07:24:49', '2020-09-22 07:24:49'),
(114, 'general.general.email_settings.shop_email_from', 'cmarchand@netysoft.com', 'default', NULL, '2020-09-22 07:24:49', '2020-09-22 07:24:49'),
(115, 'general.general.email_settings.admin_name', 'calixte MARCHAND', 'default', NULL, '2020-09-22 07:24:49', '2020-09-22 07:24:49'),
(116, 'general.general.email_settings.admin_email', 'cmarchand@netysoft.com', 'default', NULL, '2020-09-22 07:24:49', '2020-09-22 07:24:49'),
(117, 'hideshopforguest.settings.settings.hide-shop-before-login', '0', NULL, NULL, '2020-09-24 11:16:13', '2020-09-24 11:18:09'),
(118, 'hideshopforguest.settings.settings.hide-shop-before-login.notification', 'Beinvenue sur notre outil de vente', NULL, 'fr', '2020-09-24 11:16:13', '2020-09-24 11:16:13'),
(119, 'showpriceafterlogin.settings.settings.enableordisable', '1', 'default', NULL, '2020-09-24 11:18:27', '2020-09-24 11:18:27'),
(120, 'showpriceafterlogin.settings.settings.selectfunction', 'hide-price-buy-cart-guest', NULL, NULL, '2020-09-24 11:18:27', '2020-09-24 11:18:27'),
(121, 'showpriceafterlogin.settings.settings.enableordisable', '1', 'winebtob', NULL, '2020-09-30 16:23:40', '2020-09-30 16:23:40');

-- --------------------------------------------------------

--
-- Structure de la table `countries`
--

DROP TABLE IF EXISTS `countries`;
CREATE TABLE IF NOT EXISTS `countries` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=256 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `countries`
--

INSERT INTO `countries` (`id`, `code`, `name`) VALUES
(1, 'AF', 'Afghanistan'),
(2, 'AX', 'Åland Islands'),
(3, 'AL', 'Albania'),
(4, 'DZ', 'Algeria'),
(5, 'AS', 'American Samoa'),
(6, 'AD', 'Andorra'),
(7, 'AO', 'Angola'),
(8, 'AI', 'Anguilla'),
(9, 'AQ', 'Antarctica'),
(10, 'AG', 'Antigua & Barbuda'),
(11, 'AR', 'Argentina'),
(12, 'AM', 'Armenia'),
(13, 'AW', 'Aruba'),
(14, 'AC', 'Ascension Island'),
(15, 'AU', 'Australia'),
(16, 'AT', 'Austria'),
(17, 'AZ', 'Azerbaijan'),
(18, 'BS', 'Bahamas'),
(19, 'BH', 'Bahrain'),
(20, 'BD', 'Bangladesh'),
(21, 'BB', 'Barbados'),
(22, 'BY', 'Belarus'),
(23, 'BE', 'Belgium'),
(24, 'BZ', 'Belize'),
(25, 'BJ', 'Benin'),
(26, 'BM', 'Bermuda'),
(27, 'BT', 'Bhutan'),
(28, 'BO', 'Bolivia'),
(29, 'BA', 'Bosnia & Herzegovina'),
(30, 'BW', 'Botswana'),
(31, 'BR', 'Brazil'),
(32, 'IO', 'British Indian Ocean Territory'),
(33, 'VG', 'British Virgin Islands'),
(34, 'BN', 'Brunei'),
(35, 'BG', 'Bulgaria'),
(36, 'BF', 'Burkina Faso'),
(37, 'BI', 'Burundi'),
(38, 'KH', 'Cambodia'),
(39, 'CM', 'Cameroon'),
(40, 'CA', 'Canada'),
(41, 'IC', 'Canary Islands'),
(42, 'CV', 'Cape Verde'),
(43, 'BQ', 'Caribbean Netherlands'),
(44, 'KY', 'Cayman Islands'),
(45, 'CF', 'Central African Republic'),
(46, 'EA', 'Ceuta & Melilla'),
(47, 'TD', 'Chad'),
(48, 'CL', 'Chile'),
(49, 'CN', 'China'),
(50, 'CX', 'Christmas Island'),
(51, 'CC', 'Cocos (Keeling) Islands'),
(52, 'CO', 'Colombia'),
(53, 'KM', 'Comoros'),
(54, 'CG', 'Congo - Brazzaville'),
(55, 'CD', 'Congo - Kinshasa'),
(56, 'CK', 'Cook Islands'),
(57, 'CR', 'Costa Rica'),
(58, 'CI', 'Côte d’Ivoire'),
(59, 'HR', 'Croatia'),
(60, 'CU', 'Cuba'),
(61, 'CW', 'Curaçao'),
(62, 'CY', 'Cyprus'),
(63, 'CZ', 'Czechia'),
(64, 'DK', 'Denmark'),
(65, 'DG', 'Diego Garcia'),
(66, 'DJ', 'Djibouti'),
(67, 'DM', 'Dominica'),
(68, 'DO', 'Dominican Republic'),
(69, 'EC', 'Ecuador'),
(70, 'EG', 'Egypt'),
(71, 'SV', 'El Salvador'),
(72, 'GQ', 'Equatorial Guinea'),
(73, 'ER', 'Eritrea'),
(74, 'EE', 'Estonia'),
(75, 'ET', 'Ethiopia'),
(76, 'EZ', 'Eurozone'),
(77, 'FK', 'Falkland Islands'),
(78, 'FO', 'Faroe Islands'),
(79, 'FJ', 'Fiji'),
(80, 'FI', 'Finland'),
(81, 'FR', 'France'),
(82, 'GF', 'French Guiana'),
(83, 'PF', 'French Polynesia'),
(84, 'TF', 'French Southern Territories'),
(85, 'GA', 'Gabon'),
(86, 'GM', 'Gambia'),
(87, 'GE', 'Georgia'),
(88, 'DE', 'Germany'),
(89, 'GH', 'Ghana'),
(90, 'GI', 'Gibraltar'),
(91, 'GR', 'Greece'),
(92, 'GL', 'Greenland'),
(93, 'GD', 'Grenada'),
(94, 'GP', 'Guadeloupe'),
(95, 'GU', 'Guam'),
(96, 'GT', 'Guatemala'),
(97, 'GG', 'Guernsey'),
(98, 'GN', 'Guinea'),
(99, 'GW', 'Guinea-Bissau'),
(100, 'GY', 'Guyana'),
(101, 'HT', 'Haiti'),
(102, 'HN', 'Honduras'),
(103, 'HK', 'Hong Kong SAR China'),
(104, 'HU', 'Hungary'),
(105, 'IS', 'Iceland'),
(106, 'IN', 'India'),
(107, 'ID', 'Indonesia'),
(108, 'IR', 'Iran'),
(109, 'IQ', 'Iraq'),
(110, 'IE', 'Ireland'),
(111, 'IM', 'Isle of Man'),
(112, 'IL', 'Israel'),
(113, 'IT', 'Italy'),
(114, 'JM', 'Jamaica'),
(115, 'JP', 'Japan'),
(116, 'JE', 'Jersey'),
(117, 'JO', 'Jordan'),
(118, 'KZ', 'Kazakhstan'),
(119, 'KE', 'Kenya'),
(120, 'KI', 'Kiribati'),
(121, 'XK', 'Kosovo'),
(122, 'KW', 'Kuwait'),
(123, 'KG', 'Kyrgyzstan'),
(124, 'LA', 'Laos'),
(125, 'LV', 'Latvia'),
(126, 'LB', 'Lebanon'),
(127, 'LS', 'Lesotho'),
(128, 'LR', 'Liberia'),
(129, 'LY', 'Libya'),
(130, 'LI', 'Liechtenstein'),
(131, 'LT', 'Lithuania'),
(132, 'LU', 'Luxembourg'),
(133, 'MO', 'Macau SAR China'),
(134, 'MK', 'Macedonia'),
(135, 'MG', 'Madagascar'),
(136, 'MW', 'Malawi'),
(137, 'MY', 'Malaysia'),
(138, 'MV', 'Maldives'),
(139, 'ML', 'Mali'),
(140, 'MT', 'Malta'),
(141, 'MH', 'Marshall Islands'),
(142, 'MQ', 'Martinique'),
(143, 'MR', 'Mauritania'),
(144, 'MU', 'Mauritius'),
(145, 'YT', 'Mayotte'),
(146, 'MX', 'Mexico'),
(147, 'FM', 'Micronesia'),
(148, 'MD', 'Moldova'),
(149, 'MC', 'Monaco'),
(150, 'MN', 'Mongolia'),
(151, 'ME', 'Montenegro'),
(152, 'MS', 'Montserrat'),
(153, 'MA', 'Morocco'),
(154, 'MZ', 'Mozambique'),
(155, 'MM', 'Myanmar (Burma)'),
(156, 'NA', 'Namibia'),
(157, 'NR', 'Nauru'),
(158, 'NP', 'Nepal'),
(159, 'NL', 'Netherlands'),
(160, 'NC', 'New Caledonia'),
(161, 'NZ', 'New Zealand'),
(162, 'NI', 'Nicaragua'),
(163, 'NE', 'Niger'),
(164, 'NG', 'Nigeria'),
(165, 'NU', 'Niue'),
(166, 'NF', 'Norfolk Island'),
(167, 'KP', 'North Korea'),
(168, 'MP', 'Northern Mariana Islands'),
(169, 'NO', 'Norway'),
(170, 'OM', 'Oman'),
(171, 'PK', 'Pakistan'),
(172, 'PW', 'Palau'),
(173, 'PS', 'Palestinian Territories'),
(174, 'PA', 'Panama'),
(175, 'PG', 'Papua New Guinea'),
(176, 'PY', 'Paraguay'),
(177, 'PE', 'Peru'),
(178, 'PH', 'Philippines'),
(179, 'PN', 'Pitcairn Islands'),
(180, 'PL', 'Poland'),
(181, 'PT', 'Portugal'),
(182, 'PR', 'Puerto Rico'),
(183, 'QA', 'Qatar'),
(184, 'RE', 'Réunion'),
(185, 'RO', 'Romania'),
(186, 'RU', 'Russia'),
(187, 'RW', 'Rwanda'),
(188, 'WS', 'Samoa'),
(189, 'SM', 'San Marino'),
(190, 'ST', 'São Tomé & Príncipe'),
(191, 'SA', 'Saudi Arabia'),
(192, 'SN', 'Senegal'),
(193, 'RS', 'Serbia'),
(194, 'SC', 'Seychelles'),
(195, 'SL', 'Sierra Leone'),
(196, 'SG', 'Singapore'),
(197, 'SX', 'Sint Maarten'),
(198, 'SK', 'Slovakia'),
(199, 'SI', 'Slovenia'),
(200, 'SB', 'Solomon Islands'),
(201, 'SO', 'Somalia'),
(202, 'ZA', 'South Africa'),
(203, 'GS', 'South Georgia & South Sandwich Islands'),
(204, 'KR', 'South Korea'),
(205, 'SS', 'South Sudan'),
(206, 'ES', 'Spain'),
(207, 'LK', 'Sri Lanka'),
(208, 'BL', 'St. Barthélemy'),
(209, 'SH', 'St. Helena'),
(210, 'KN', 'St. Kitts & Nevis'),
(211, 'LC', 'St. Lucia'),
(212, 'MF', 'St. Martin'),
(213, 'PM', 'St. Pierre & Miquelon'),
(214, 'VC', 'St. Vincent & Grenadines'),
(215, 'SD', 'Sudan'),
(216, 'SR', 'Suriname'),
(217, 'SJ', 'Svalbard & Jan Mayen'),
(218, 'SZ', 'Swaziland'),
(219, 'SE', 'Sweden'),
(220, 'CH', 'Switzerland'),
(221, 'SY', 'Syria'),
(222, 'TW', 'Taiwan'),
(223, 'TJ', 'Tajikistan'),
(224, 'TZ', 'Tanzania'),
(225, 'TH', 'Thailand'),
(226, 'TL', 'Timor-Leste'),
(227, 'TG', 'Togo'),
(228, 'TK', 'Tokelau'),
(229, 'TO', 'Tonga'),
(230, 'TT', 'Trinidad & Tobago'),
(231, 'TA', 'Tristan da Cunha'),
(232, 'TN', 'Tunisia'),
(233, 'TR', 'Turkey'),
(234, 'TM', 'Turkmenistan'),
(235, 'TC', 'Turks & Caicos Islands'),
(236, 'TV', 'Tuvalu'),
(237, 'UM', 'U.S. Outlying Islands'),
(238, 'VI', 'U.S. Virgin Islands'),
(239, 'UG', 'Uganda'),
(240, 'UA', 'Ukraine'),
(241, 'AE', 'United Arab Emirates'),
(242, 'GB', 'United Kingdom'),
(243, 'UN', 'United Nations'),
(244, 'US', 'United States'),
(245, 'UY', 'Uruguay'),
(246, 'UZ', 'Uzbekistan'),
(247, 'VU', 'Vanuatu'),
(248, 'VA', 'Vatican City'),
(249, 'VE', 'Venezuela'),
(250, 'VN', 'Vietnam'),
(251, 'WF', 'Wallis & Futuna'),
(252, 'EH', 'Western Sahara'),
(253, 'YE', 'Yemen'),
(254, 'ZM', 'Zambia'),
(255, 'ZW', 'Zimbabwe');

-- --------------------------------------------------------

--
-- Structure de la table `country_states`
--

DROP TABLE IF EXISTS `country_states`;
CREATE TABLE IF NOT EXISTS `country_states` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `country_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_id` int UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `country_states_country_id_foreign` (`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=569 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `country_states`
--

INSERT INTO `country_states` (`id`, `country_code`, `code`, `default_name`, `country_id`) VALUES
(1, 'US', 'AL', 'Alabama', 244),
(2, 'US', 'AK', 'Alaska', 244),
(3, 'US', 'AS', 'American Samoa', 244),
(4, 'US', 'AZ', 'Arizona', 244),
(5, 'US', 'AR', 'Arkansas', 244),
(6, 'US', 'AE', 'Armed Forces Africa', 244),
(7, 'US', 'AA', 'Armed Forces Americas', 244),
(8, 'US', 'AE', 'Armed Forces Canada', 244),
(9, 'US', 'AE', 'Armed Forces Europe', 244),
(10, 'US', 'AE', 'Armed Forces Middle East', 244),
(11, 'US', 'AP', 'Armed Forces Pacific', 244),
(12, 'US', 'CA', 'California', 244),
(13, 'US', 'CO', 'Colorado', 244),
(14, 'US', 'CT', 'Connecticut', 244),
(15, 'US', 'DE', 'Delaware', 244),
(16, 'US', 'DC', 'District of Columbia', 244),
(17, 'US', 'FM', 'Federated States Of Micronesia', 244),
(18, 'US', 'FL', 'Florida', 244),
(19, 'US', 'GA', 'Georgia', 244),
(20, 'US', 'GU', 'Guam', 244),
(21, 'US', 'HI', 'Hawaii', 244),
(22, 'US', 'ID', 'Idaho', 244),
(23, 'US', 'IL', 'Illinois', 244),
(24, 'US', 'IN', 'Indiana', 244),
(25, 'US', 'IA', 'Iowa', 244),
(26, 'US', 'KS', 'Kansas', 244),
(27, 'US', 'KY', 'Kentucky', 244),
(28, 'US', 'LA', 'Louisiana', 244),
(29, 'US', 'ME', 'Maine', 244),
(30, 'US', 'MH', 'Marshall Islands', 244),
(31, 'US', 'MD', 'Maryland', 244),
(32, 'US', 'MA', 'Massachusetts', 244),
(33, 'US', 'MI', 'Michigan', 244),
(34, 'US', 'MN', 'Minnesota', 244),
(35, 'US', 'MS', 'Mississippi', 244),
(36, 'US', 'MO', 'Missouri', 244),
(37, 'US', 'MT', 'Montana', 244),
(38, 'US', 'NE', 'Nebraska', 244),
(39, 'US', 'NV', 'Nevada', 244),
(40, 'US', 'NH', 'New Hampshire', 244),
(41, 'US', 'NJ', 'New Jersey', 244),
(42, 'US', 'NM', 'New Mexico', 244),
(43, 'US', 'NY', 'New York', 244),
(44, 'US', 'NC', 'North Carolina', 244),
(45, 'US', 'ND', 'North Dakota', 244),
(46, 'US', 'MP', 'Northern Mariana Islands', 244),
(47, 'US', 'OH', 'Ohio', 244),
(48, 'US', 'OK', 'Oklahoma', 244),
(49, 'US', 'OR', 'Oregon', 244),
(50, 'US', 'PW', 'Palau', 244),
(51, 'US', 'PA', 'Pennsylvania', 244),
(52, 'US', 'PR', 'Puerto Rico', 244),
(53, 'US', 'RI', 'Rhode Island', 244),
(54, 'US', 'SC', 'South Carolina', 244),
(55, 'US', 'SD', 'South Dakota', 244),
(56, 'US', 'TN', 'Tennessee', 244),
(57, 'US', 'TX', 'Texas', 244),
(58, 'US', 'UT', 'Utah', 244),
(59, 'US', 'VT', 'Vermont', 244),
(60, 'US', 'VI', 'Virgin Islands', 244),
(61, 'US', 'VA', 'Virginia', 244),
(62, 'US', 'WA', 'Washington', 244),
(63, 'US', 'WV', 'West Virginia', 244),
(64, 'US', 'WI', 'Wisconsin', 244),
(65, 'US', 'WY', 'Wyoming', 244),
(66, 'CA', 'AB', 'Alberta', 40),
(67, 'CA', 'BC', 'British Columbia', 40),
(68, 'CA', 'MB', 'Manitoba', 40),
(69, 'CA', 'NL', 'Newfoundland and Labrador', 40),
(70, 'CA', 'NB', 'New Brunswick', 40),
(71, 'CA', 'NS', 'Nova Scotia', 40),
(72, 'CA', 'NT', 'Northwest Territories', 40),
(73, 'CA', 'NU', 'Nunavut', 40),
(74, 'CA', 'ON', 'Ontario', 40),
(75, 'CA', 'PE', 'Prince Edward Island', 40),
(76, 'CA', 'QC', 'Quebec', 40),
(77, 'CA', 'SK', 'Saskatchewan', 40),
(78, 'CA', 'YT', 'Yukon Territory', 40),
(79, 'DE', 'NDS', 'Niedersachsen', 88),
(80, 'DE', 'BAW', 'Baden-Württemberg', 88),
(81, 'DE', 'BAY', 'Bayern', 88),
(82, 'DE', 'BER', 'Berlin', 88),
(83, 'DE', 'BRG', 'Brandenburg', 88),
(84, 'DE', 'BRE', 'Bremen', 88),
(85, 'DE', 'HAM', 'Hamburg', 88),
(86, 'DE', 'HES', 'Hessen', 88),
(87, 'DE', 'MEC', 'Mecklenburg-Vorpommern', 88),
(88, 'DE', 'NRW', 'Nordrhein-Westfalen', 88),
(89, 'DE', 'RHE', 'Rheinland-Pfalz', 88),
(90, 'DE', 'SAR', 'Saarland', 88),
(91, 'DE', 'SAS', 'Sachsen', 88),
(92, 'DE', 'SAC', 'Sachsen-Anhalt', 88),
(93, 'DE', 'SCN', 'Schleswig-Holstein', 88),
(94, 'DE', 'THE', 'Thüringen', 88),
(95, 'AT', 'WI', 'Wien', 16),
(96, 'AT', 'NO', 'Niederösterreich', 16),
(97, 'AT', 'OO', 'Oberösterreich', 16),
(98, 'AT', 'SB', 'Salzburg', 16),
(99, 'AT', 'KN', 'Kärnten', 16),
(100, 'AT', 'ST', 'Steiermark', 16),
(101, 'AT', 'TI', 'Tirol', 16),
(102, 'AT', 'BL', 'Burgenland', 16),
(103, 'AT', 'VB', 'Vorarlberg', 16),
(104, 'CH', 'AG', 'Aargau', 220),
(105, 'CH', 'AI', 'Appenzell Innerrhoden', 220),
(106, 'CH', 'AR', 'Appenzell Ausserrhoden', 220),
(107, 'CH', 'BE', 'Bern', 220),
(108, 'CH', 'BL', 'Basel-Landschaft', 220),
(109, 'CH', 'BS', 'Basel-Stadt', 220),
(110, 'CH', 'FR', 'Freiburg', 220),
(111, 'CH', 'GE', 'Genf', 220),
(112, 'CH', 'GL', 'Glarus', 220),
(113, 'CH', 'GR', 'Graubünden', 220),
(114, 'CH', 'JU', 'Jura', 220),
(115, 'CH', 'LU', 'Luzern', 220),
(116, 'CH', 'NE', 'Neuenburg', 220),
(117, 'CH', 'NW', 'Nidwalden', 220),
(118, 'CH', 'OW', 'Obwalden', 220),
(119, 'CH', 'SG', 'St. Gallen', 220),
(120, 'CH', 'SH', 'Schaffhausen', 220),
(121, 'CH', 'SO', 'Solothurn', 220),
(122, 'CH', 'SZ', 'Schwyz', 220),
(123, 'CH', 'TG', 'Thurgau', 220),
(124, 'CH', 'TI', 'Tessin', 220),
(125, 'CH', 'UR', 'Uri', 220),
(126, 'CH', 'VD', 'Waadt', 220),
(127, 'CH', 'VS', 'Wallis', 220),
(128, 'CH', 'ZG', 'Zug', 220),
(129, 'CH', 'ZH', 'Zürich', 220),
(130, 'ES', 'A Coruсa', 'A Coruña', 206),
(131, 'ES', 'Alava', 'Alava', 206),
(132, 'ES', 'Albacete', 'Albacete', 206),
(133, 'ES', 'Alicante', 'Alicante', 206),
(134, 'ES', 'Almeria', 'Almeria', 206),
(135, 'ES', 'Asturias', 'Asturias', 206),
(136, 'ES', 'Avila', 'Avila', 206),
(137, 'ES', 'Badajoz', 'Badajoz', 206),
(138, 'ES', 'Baleares', 'Baleares', 206),
(139, 'ES', 'Barcelona', 'Barcelona', 206),
(140, 'ES', 'Burgos', 'Burgos', 206),
(141, 'ES', 'Caceres', 'Caceres', 206),
(142, 'ES', 'Cadiz', 'Cadiz', 206),
(143, 'ES', 'Cantabria', 'Cantabria', 206),
(144, 'ES', 'Castellon', 'Castellon', 206),
(145, 'ES', 'Ceuta', 'Ceuta', 206),
(146, 'ES', 'Ciudad Real', 'Ciudad Real', 206),
(147, 'ES', 'Cordoba', 'Cordoba', 206),
(148, 'ES', 'Cuenca', 'Cuenca', 206),
(149, 'ES', 'Girona', 'Girona', 206),
(150, 'ES', 'Granada', 'Granada', 206),
(151, 'ES', 'Guadalajara', 'Guadalajara', 206),
(152, 'ES', 'Guipuzcoa', 'Guipuzcoa', 206),
(153, 'ES', 'Huelva', 'Huelva', 206),
(154, 'ES', 'Huesca', 'Huesca', 206),
(155, 'ES', 'Jaen', 'Jaen', 206),
(156, 'ES', 'La Rioja', 'La Rioja', 206),
(157, 'ES', 'Las Palmas', 'Las Palmas', 206),
(158, 'ES', 'Leon', 'Leon', 206),
(159, 'ES', 'Lleida', 'Lleida', 206),
(160, 'ES', 'Lugo', 'Lugo', 206),
(161, 'ES', 'Madrid', 'Madrid', 206),
(162, 'ES', 'Malaga', 'Malaga', 206),
(163, 'ES', 'Melilla', 'Melilla', 206),
(164, 'ES', 'Murcia', 'Murcia', 206),
(165, 'ES', 'Navarra', 'Navarra', 206),
(166, 'ES', 'Ourense', 'Ourense', 206),
(167, 'ES', 'Palencia', 'Palencia', 206),
(168, 'ES', 'Pontevedra', 'Pontevedra', 206),
(169, 'ES', 'Salamanca', 'Salamanca', 206),
(170, 'ES', 'Santa Cruz de Tenerife', 'Santa Cruz de Tenerife', 206),
(171, 'ES', 'Segovia', 'Segovia', 206),
(172, 'ES', 'Sevilla', 'Sevilla', 206),
(173, 'ES', 'Soria', 'Soria', 206),
(174, 'ES', 'Tarragona', 'Tarragona', 206),
(175, 'ES', 'Teruel', 'Teruel', 206),
(176, 'ES', 'Toledo', 'Toledo', 206),
(177, 'ES', 'Valencia', 'Valencia', 206),
(178, 'ES', 'Valladolid', 'Valladolid', 206),
(179, 'ES', 'Vizcaya', 'Vizcaya', 206),
(180, 'ES', 'Zamora', 'Zamora', 206),
(181, 'ES', 'Zaragoza', 'Zaragoza', 206),
(182, 'FR', '1', 'Ain', 81),
(183, 'FR', '2', 'Aisne', 81),
(184, 'FR', '3', 'Allier', 81),
(185, 'FR', '4', 'Alpes-de-Haute-Provence', 81),
(186, 'FR', '5', 'Hautes-Alpes', 81),
(187, 'FR', '6', 'Alpes-Maritimes', 81),
(188, 'FR', '7', 'Ardèche', 81),
(189, 'FR', '8', 'Ardennes', 81),
(190, 'FR', '9', 'Ariège', 81),
(191, 'FR', '10', 'Aube', 81),
(192, 'FR', '11', 'Aude', 81),
(193, 'FR', '12', 'Aveyron', 81),
(194, 'FR', '13', 'Bouches-du-Rhône', 81),
(195, 'FR', '14', 'Calvados', 81),
(196, 'FR', '15', 'Cantal', 81),
(197, 'FR', '16', 'Charente', 81),
(198, 'FR', '17', 'Charente-Maritime', 81),
(199, 'FR', '18', 'Cher', 81),
(200, 'FR', '19', 'Corrèze', 81),
(201, 'FR', '2A', 'Corse-du-Sud', 81),
(202, 'FR', '2B', 'Haute-Corse', 81),
(203, 'FR', '21', 'Côte-d\'Or', 81),
(204, 'FR', '22', 'Côtes-d\'Armor', 81),
(205, 'FR', '23', 'Creuse', 81),
(206, 'FR', '24', 'Dordogne', 81),
(207, 'FR', '25', 'Doubs', 81),
(208, 'FR', '26', 'Drôme', 81),
(209, 'FR', '27', 'Eure', 81),
(210, 'FR', '28', 'Eure-et-Loir', 81),
(211, 'FR', '29', 'Finistère', 81),
(212, 'FR', '30', 'Gard', 81),
(213, 'FR', '31', 'Haute-Garonne', 81),
(214, 'FR', '32', 'Gers', 81),
(215, 'FR', '33', 'Gironde', 81),
(216, 'FR', '34', 'Hérault', 81),
(217, 'FR', '35', 'Ille-et-Vilaine', 81),
(218, 'FR', '36', 'Indre', 81),
(219, 'FR', '37', 'Indre-et-Loire', 81),
(220, 'FR', '38', 'Isère', 81),
(221, 'FR', '39', 'Jura', 81),
(222, 'FR', '40', 'Landes', 81),
(223, 'FR', '41', 'Loir-et-Cher', 81),
(224, 'FR', '42', 'Loire', 81),
(225, 'FR', '43', 'Haute-Loire', 81),
(226, 'FR', '44', 'Loire-Atlantique', 81),
(227, 'FR', '45', 'Loiret', 81),
(228, 'FR', '46', 'Lot', 81),
(229, 'FR', '47', 'Lot-et-Garonne', 81),
(230, 'FR', '48', 'Lozère', 81),
(231, 'FR', '49', 'Maine-et-Loire', 81),
(232, 'FR', '50', 'Manche', 81),
(233, 'FR', '51', 'Marne', 81),
(234, 'FR', '52', 'Haute-Marne', 81),
(235, 'FR', '53', 'Mayenne', 81),
(236, 'FR', '54', 'Meurthe-et-Moselle', 81),
(237, 'FR', '55', 'Meuse', 81),
(238, 'FR', '56', 'Morbihan', 81),
(239, 'FR', '57', 'Moselle', 81),
(240, 'FR', '58', 'Nièvre', 81),
(241, 'FR', '59', 'Nord', 81),
(242, 'FR', '60', 'Oise', 81),
(243, 'FR', '61', 'Orne', 81),
(244, 'FR', '62', 'Pas-de-Calais', 81),
(245, 'FR', '63', 'Puy-de-Dôme', 81),
(246, 'FR', '64', 'Pyrénées-Atlantiques', 81),
(247, 'FR', '65', 'Hautes-Pyrénées', 81),
(248, 'FR', '66', 'Pyrénées-Orientales', 81),
(249, 'FR', '67', 'Bas-Rhin', 81),
(250, 'FR', '68', 'Haut-Rhin', 81),
(251, 'FR', '69', 'Rhône', 81),
(252, 'FR', '70', 'Haute-Saône', 81),
(253, 'FR', '71', 'Saône-et-Loire', 81),
(254, 'FR', '72', 'Sarthe', 81),
(255, 'FR', '73', 'Savoie', 81),
(256, 'FR', '74', 'Haute-Savoie', 81),
(257, 'FR', '75', 'Paris', 81),
(258, 'FR', '76', 'Seine-Maritime', 81),
(259, 'FR', '77', 'Seine-et-Marne', 81),
(260, 'FR', '78', 'Yvelines', 81),
(261, 'FR', '79', 'Deux-Sèvres', 81),
(262, 'FR', '80', 'Somme', 81),
(263, 'FR', '81', 'Tarn', 81),
(264, 'FR', '82', 'Tarn-et-Garonne', 81),
(265, 'FR', '83', 'Var', 81),
(266, 'FR', '84', 'Vaucluse', 81),
(267, 'FR', '85', 'Vendée', 81),
(268, 'FR', '86', 'Vienne', 81),
(269, 'FR', '87', 'Haute-Vienne', 81),
(270, 'FR', '88', 'Vosges', 81),
(271, 'FR', '89', 'Yonne', 81),
(272, 'FR', '90', 'Territoire-de-Belfort', 81),
(273, 'FR', '91', 'Essonne', 81),
(274, 'FR', '92', 'Hauts-de-Seine', 81),
(275, 'FR', '93', 'Seine-Saint-Denis', 81),
(276, 'FR', '94', 'Val-de-Marne', 81),
(277, 'FR', '95', 'Val-d\'Oise', 81),
(278, 'RO', 'AB', 'Alba', 185),
(279, 'RO', 'AR', 'Arad', 185),
(280, 'RO', 'AG', 'Argeş', 185),
(281, 'RO', 'BC', 'Bacău', 185),
(282, 'RO', 'BH', 'Bihor', 185),
(283, 'RO', 'BN', 'Bistriţa-Năsăud', 185),
(284, 'RO', 'BT', 'Botoşani', 185),
(285, 'RO', 'BV', 'Braşov', 185),
(286, 'RO', 'BR', 'Brăila', 185),
(287, 'RO', 'B', 'Bucureşti', 185),
(288, 'RO', 'BZ', 'Buzău', 185),
(289, 'RO', 'CS', 'Caraş-Severin', 185),
(290, 'RO', 'CL', 'Călăraşi', 185),
(291, 'RO', 'CJ', 'Cluj', 185),
(292, 'RO', 'CT', 'Constanţa', 185),
(293, 'RO', 'CV', 'Covasna', 185),
(294, 'RO', 'DB', 'Dâmboviţa', 185),
(295, 'RO', 'DJ', 'Dolj', 185),
(296, 'RO', 'GL', 'Galaţi', 185),
(297, 'RO', 'GR', 'Giurgiu', 185),
(298, 'RO', 'GJ', 'Gorj', 185),
(299, 'RO', 'HR', 'Harghita', 185),
(300, 'RO', 'HD', 'Hunedoara', 185),
(301, 'RO', 'IL', 'Ialomiţa', 185),
(302, 'RO', 'IS', 'Iaşi', 185),
(303, 'RO', 'IF', 'Ilfov', 185),
(304, 'RO', 'MM', 'Maramureş', 185),
(305, 'RO', 'MH', 'Mehedinţi', 185),
(306, 'RO', 'MS', 'Mureş', 185),
(307, 'RO', 'NT', 'Neamţ', 185),
(308, 'RO', 'OT', 'Olt', 185),
(309, 'RO', 'PH', 'Prahova', 185),
(310, 'RO', 'SM', 'Satu-Mare', 185),
(311, 'RO', 'SJ', 'Sălaj', 185),
(312, 'RO', 'SB', 'Sibiu', 185),
(313, 'RO', 'SV', 'Suceava', 185),
(314, 'RO', 'TR', 'Teleorman', 185),
(315, 'RO', 'TM', 'Timiş', 185),
(316, 'RO', 'TL', 'Tulcea', 185),
(317, 'RO', 'VS', 'Vaslui', 185),
(318, 'RO', 'VL', 'Vâlcea', 185),
(319, 'RO', 'VN', 'Vrancea', 185),
(320, 'FI', 'Lappi', 'Lappi', 80),
(321, 'FI', 'Pohjois-Pohjanmaa', 'Pohjois-Pohjanmaa', 80),
(322, 'FI', 'Kainuu', 'Kainuu', 80),
(323, 'FI', 'Pohjois-Karjala', 'Pohjois-Karjala', 80),
(324, 'FI', 'Pohjois-Savo', 'Pohjois-Savo', 80),
(325, 'FI', 'Etelä-Savo', 'Etelä-Savo', 80),
(326, 'FI', 'Etelä-Pohjanmaa', 'Etelä-Pohjanmaa', 80),
(327, 'FI', 'Pohjanmaa', 'Pohjanmaa', 80),
(328, 'FI', 'Pirkanmaa', 'Pirkanmaa', 80),
(329, 'FI', 'Satakunta', 'Satakunta', 80),
(330, 'FI', 'Keski-Pohjanmaa', 'Keski-Pohjanmaa', 80),
(331, 'FI', 'Keski-Suomi', 'Keski-Suomi', 80),
(332, 'FI', 'Varsinais-Suomi', 'Varsinais-Suomi', 80),
(333, 'FI', 'Etelä-Karjala', 'Etelä-Karjala', 80),
(334, 'FI', 'Päijät-Häme', 'Päijät-Häme', 80),
(335, 'FI', 'Kanta-Häme', 'Kanta-Häme', 80),
(336, 'FI', 'Uusimaa', 'Uusimaa', 80),
(337, 'FI', 'Itä-Uusimaa', 'Itä-Uusimaa', 80),
(338, 'FI', 'Kymenlaakso', 'Kymenlaakso', 80),
(339, 'FI', 'Ahvenanmaa', 'Ahvenanmaa', 80),
(340, 'EE', 'EE-37', 'Harjumaa', 74),
(341, 'EE', 'EE-39', 'Hiiumaa', 74),
(342, 'EE', 'EE-44', 'Ida-Virumaa', 74),
(343, 'EE', 'EE-49', 'Jõgevamaa', 74),
(344, 'EE', 'EE-51', 'Järvamaa', 74),
(345, 'EE', 'EE-57', 'Läänemaa', 74),
(346, 'EE', 'EE-59', 'Lääne-Virumaa', 74),
(347, 'EE', 'EE-65', 'Põlvamaa', 74),
(348, 'EE', 'EE-67', 'Pärnumaa', 74),
(349, 'EE', 'EE-70', 'Raplamaa', 74),
(350, 'EE', 'EE-74', 'Saaremaa', 74),
(351, 'EE', 'EE-78', 'Tartumaa', 74),
(352, 'EE', 'EE-82', 'Valgamaa', 74),
(353, 'EE', 'EE-84', 'Viljandimaa', 74),
(354, 'EE', 'EE-86', 'Võrumaa', 74),
(355, 'LV', 'LV-DGV', 'Daugavpils', 125),
(356, 'LV', 'LV-JEL', 'Jelgava', 125),
(357, 'LV', 'Jēkabpils', 'Jēkabpils', 125),
(358, 'LV', 'LV-JUR', 'Jūrmala', 125),
(359, 'LV', 'LV-LPX', 'Liepāja', 125),
(360, 'LV', 'LV-LE', 'Liepājas novads', 125),
(361, 'LV', 'LV-REZ', 'Rēzekne', 125),
(362, 'LV', 'LV-RIX', 'Rīga', 125),
(363, 'LV', 'LV-RI', 'Rīgas novads', 125),
(364, 'LV', 'Valmiera', 'Valmiera', 125),
(365, 'LV', 'LV-VEN', 'Ventspils', 125),
(366, 'LV', 'Aglonas novads', 'Aglonas novads', 125),
(367, 'LV', 'LV-AI', 'Aizkraukles novads', 125),
(368, 'LV', 'Aizputes novads', 'Aizputes novads', 125),
(369, 'LV', 'Aknīstes novads', 'Aknīstes novads', 125),
(370, 'LV', 'Alojas novads', 'Alojas novads', 125),
(371, 'LV', 'Alsungas novads', 'Alsungas novads', 125),
(372, 'LV', 'LV-AL', 'Alūksnes novads', 125),
(373, 'LV', 'Amatas novads', 'Amatas novads', 125),
(374, 'LV', 'Apes novads', 'Apes novads', 125),
(375, 'LV', 'Auces novads', 'Auces novads', 125),
(376, 'LV', 'Babītes novads', 'Babītes novads', 125),
(377, 'LV', 'Baldones novads', 'Baldones novads', 125),
(378, 'LV', 'Baltinavas novads', 'Baltinavas novads', 125),
(379, 'LV', 'LV-BL', 'Balvu novads', 125),
(380, 'LV', 'LV-BU', 'Bauskas novads', 125),
(381, 'LV', 'Beverīnas novads', 'Beverīnas novads', 125),
(382, 'LV', 'Brocēnu novads', 'Brocēnu novads', 125),
(383, 'LV', 'Burtnieku novads', 'Burtnieku novads', 125),
(384, 'LV', 'Carnikavas novads', 'Carnikavas novads', 125),
(385, 'LV', 'Cesvaines novads', 'Cesvaines novads', 125),
(386, 'LV', 'Ciblas novads', 'Ciblas novads', 125),
(387, 'LV', 'LV-CE', 'Cēsu novads', 125),
(388, 'LV', 'Dagdas novads', 'Dagdas novads', 125),
(389, 'LV', 'LV-DA', 'Daugavpils novads', 125),
(390, 'LV', 'LV-DO', 'Dobeles novads', 125),
(391, 'LV', 'Dundagas novads', 'Dundagas novads', 125),
(392, 'LV', 'Durbes novads', 'Durbes novads', 125),
(393, 'LV', 'Engures novads', 'Engures novads', 125),
(394, 'LV', 'Garkalnes novads', 'Garkalnes novads', 125),
(395, 'LV', 'Grobiņas novads', 'Grobiņas novads', 125),
(396, 'LV', 'LV-GU', 'Gulbenes novads', 125),
(397, 'LV', 'Iecavas novads', 'Iecavas novads', 125),
(398, 'LV', 'Ikšķiles novads', 'Ikšķiles novads', 125),
(399, 'LV', 'Ilūkstes novads', 'Ilūkstes novads', 125),
(400, 'LV', 'Inčukalna novads', 'Inčukalna novads', 125),
(401, 'LV', 'Jaunjelgavas novads', 'Jaunjelgavas novads', 125),
(402, 'LV', 'Jaunpiebalgas novads', 'Jaunpiebalgas novads', 125),
(403, 'LV', 'Jaunpils novads', 'Jaunpils novads', 125),
(404, 'LV', 'LV-JL', 'Jelgavas novads', 125),
(405, 'LV', 'LV-JK', 'Jēkabpils novads', 125),
(406, 'LV', 'Kandavas novads', 'Kandavas novads', 125),
(407, 'LV', 'Kokneses novads', 'Kokneses novads', 125),
(408, 'LV', 'Krimuldas novads', 'Krimuldas novads', 125),
(409, 'LV', 'Krustpils novads', 'Krustpils novads', 125),
(410, 'LV', 'LV-KR', 'Krāslavas novads', 125),
(411, 'LV', 'LV-KU', 'Kuldīgas novads', 125),
(412, 'LV', 'Kārsavas novads', 'Kārsavas novads', 125),
(413, 'LV', 'Lielvārdes novads', 'Lielvārdes novads', 125),
(414, 'LV', 'LV-LM', 'Limbažu novads', 125),
(415, 'LV', 'Lubānas novads', 'Lubānas novads', 125),
(416, 'LV', 'LV-LU', 'Ludzas novads', 125),
(417, 'LV', 'Līgatnes novads', 'Līgatnes novads', 125),
(418, 'LV', 'Līvānu novads', 'Līvānu novads', 125),
(419, 'LV', 'LV-MA', 'Madonas novads', 125),
(420, 'LV', 'Mazsalacas novads', 'Mazsalacas novads', 125),
(421, 'LV', 'Mālpils novads', 'Mālpils novads', 125),
(422, 'LV', 'Mārupes novads', 'Mārupes novads', 125),
(423, 'LV', 'Naukšēnu novads', 'Naukšēnu novads', 125),
(424, 'LV', 'Neretas novads', 'Neretas novads', 125),
(425, 'LV', 'Nīcas novads', 'Nīcas novads', 125),
(426, 'LV', 'LV-OG', 'Ogres novads', 125),
(427, 'LV', 'Olaines novads', 'Olaines novads', 125),
(428, 'LV', 'Ozolnieku novads', 'Ozolnieku novads', 125),
(429, 'LV', 'LV-PR', 'Preiļu novads', 125),
(430, 'LV', 'Priekules novads', 'Priekules novads', 125),
(431, 'LV', 'Priekuļu novads', 'Priekuļu novads', 125),
(432, 'LV', 'Pārgaujas novads', 'Pārgaujas novads', 125),
(433, 'LV', 'Pāvilostas novads', 'Pāvilostas novads', 125),
(434, 'LV', 'Pļaviņu novads', 'Pļaviņu novads', 125),
(435, 'LV', 'Raunas novads', 'Raunas novads', 125),
(436, 'LV', 'Riebiņu novads', 'Riebiņu novads', 125),
(437, 'LV', 'Rojas novads', 'Rojas novads', 125),
(438, 'LV', 'Ropažu novads', 'Ropažu novads', 125),
(439, 'LV', 'Rucavas novads', 'Rucavas novads', 125),
(440, 'LV', 'Rugāju novads', 'Rugāju novads', 125),
(441, 'LV', 'Rundāles novads', 'Rundāles novads', 125),
(442, 'LV', 'LV-RE', 'Rēzeknes novads', 125),
(443, 'LV', 'Rūjienas novads', 'Rūjienas novads', 125),
(444, 'LV', 'Salacgrīvas novads', 'Salacgrīvas novads', 125),
(445, 'LV', 'Salas novads', 'Salas novads', 125),
(446, 'LV', 'Salaspils novads', 'Salaspils novads', 125),
(447, 'LV', 'LV-SA', 'Saldus novads', 125),
(448, 'LV', 'Saulkrastu novads', 'Saulkrastu novads', 125),
(449, 'LV', 'Siguldas novads', 'Siguldas novads', 125),
(450, 'LV', 'Skrundas novads', 'Skrundas novads', 125),
(451, 'LV', 'Skrīveru novads', 'Skrīveru novads', 125),
(452, 'LV', 'Smiltenes novads', 'Smiltenes novads', 125),
(453, 'LV', 'Stopiņu novads', 'Stopiņu novads', 125),
(454, 'LV', 'Strenču novads', 'Strenču novads', 125),
(455, 'LV', 'Sējas novads', 'Sējas novads', 125),
(456, 'LV', 'LV-TA', 'Talsu novads', 125),
(457, 'LV', 'LV-TU', 'Tukuma novads', 125),
(458, 'LV', 'Tērvetes novads', 'Tērvetes novads', 125),
(459, 'LV', 'Vaiņodes novads', 'Vaiņodes novads', 125),
(460, 'LV', 'LV-VK', 'Valkas novads', 125),
(461, 'LV', 'LV-VM', 'Valmieras novads', 125),
(462, 'LV', 'Varakļānu novads', 'Varakļānu novads', 125),
(463, 'LV', 'Vecpiebalgas novads', 'Vecpiebalgas novads', 125),
(464, 'LV', 'Vecumnieku novads', 'Vecumnieku novads', 125),
(465, 'LV', 'LV-VE', 'Ventspils novads', 125),
(466, 'LV', 'Viesītes novads', 'Viesītes novads', 125),
(467, 'LV', 'Viļakas novads', 'Viļakas novads', 125),
(468, 'LV', 'Viļānu novads', 'Viļānu novads', 125),
(469, 'LV', 'Vārkavas novads', 'Vārkavas novads', 125),
(470, 'LV', 'Zilupes novads', 'Zilupes novads', 125),
(471, 'LV', 'Ādažu novads', 'Ādažu novads', 125),
(472, 'LV', 'Ērgļu novads', 'Ērgļu novads', 125),
(473, 'LV', 'Ķeguma novads', 'Ķeguma novads', 125),
(474, 'LV', 'Ķekavas novads', 'Ķekavas novads', 125),
(475, 'LT', 'LT-AL', 'Alytaus Apskritis', 131),
(476, 'LT', 'LT-KU', 'Kauno Apskritis', 131),
(477, 'LT', 'LT-KL', 'Klaipėdos Apskritis', 131),
(478, 'LT', 'LT-MR', 'Marijampolės Apskritis', 131),
(479, 'LT', 'LT-PN', 'Panevėžio Apskritis', 131),
(480, 'LT', 'LT-SA', 'Šiaulių Apskritis', 131),
(481, 'LT', 'LT-TA', 'Tauragės Apskritis', 131),
(482, 'LT', 'LT-TE', 'Telšių Apskritis', 131),
(483, 'LT', 'LT-UT', 'Utenos Apskritis', 131),
(484, 'LT', 'LT-VL', 'Vilniaus Apskritis', 131),
(485, 'BR', 'AC', 'Acre', 31),
(486, 'BR', 'AL', 'Alagoas', 31),
(487, 'BR', 'AP', 'Amapá', 31),
(488, 'BR', 'AM', 'Amazonas', 31),
(489, 'BR', 'BA', 'Bahia', 31),
(490, 'BR', 'CE', 'Ceará', 31),
(491, 'BR', 'ES', 'Espírito Santo', 31),
(492, 'BR', 'GO', 'Goiás', 31),
(493, 'BR', 'MA', 'Maranhão', 31),
(494, 'BR', 'MT', 'Mato Grosso', 31),
(495, 'BR', 'MS', 'Mato Grosso do Sul', 31),
(496, 'BR', 'MG', 'Minas Gerais', 31),
(497, 'BR', 'PA', 'Pará', 31),
(498, 'BR', 'PB', 'Paraíba', 31),
(499, 'BR', 'PR', 'Paraná', 31),
(500, 'BR', 'PE', 'Pernambuco', 31),
(501, 'BR', 'PI', 'Piauí', 31),
(502, 'BR', 'RJ', 'Rio de Janeiro', 31),
(503, 'BR', 'RN', 'Rio Grande do Norte', 31),
(504, 'BR', 'RS', 'Rio Grande do Sul', 31),
(505, 'BR', 'RO', 'Rondônia', 31),
(506, 'BR', 'RR', 'Roraima', 31),
(507, 'BR', 'SC', 'Santa Catarina', 31),
(508, 'BR', 'SP', 'São Paulo', 31),
(509, 'BR', 'SE', 'Sergipe', 31),
(510, 'BR', 'TO', 'Tocantins', 31),
(511, 'BR', 'DF', 'Distrito Federal', 31),
(512, 'HR', 'HR-01', 'Zagrebačka županija', 59),
(513, 'HR', 'HR-02', 'Krapinsko-zagorska županija', 59),
(514, 'HR', 'HR-03', 'Sisačko-moslavačka županija', 59),
(515, 'HR', 'HR-04', 'Karlovačka županija', 59),
(516, 'HR', 'HR-05', 'Varaždinska županija', 59),
(517, 'HR', 'HR-06', 'Koprivničko-križevačka županija', 59),
(518, 'HR', 'HR-07', 'Bjelovarsko-bilogorska županija', 59),
(519, 'HR', 'HR-08', 'Primorsko-goranska županija', 59),
(520, 'HR', 'HR-09', 'Ličko-senjska županija', 59),
(521, 'HR', 'HR-10', 'Virovitičko-podravska županija', 59),
(522, 'HR', 'HR-11', 'Požeško-slavonska županija', 59),
(523, 'HR', 'HR-12', 'Brodsko-posavska županija', 59),
(524, 'HR', 'HR-13', 'Zadarska županija', 59),
(525, 'HR', 'HR-14', 'Osječko-baranjska županija', 59),
(526, 'HR', 'HR-15', 'Šibensko-kninska županija', 59),
(527, 'HR', 'HR-16', 'Vukovarsko-srijemska županija', 59),
(528, 'HR', 'HR-17', 'Splitsko-dalmatinska županija', 59),
(529, 'HR', 'HR-18', 'Istarska županija', 59),
(530, 'HR', 'HR-19', 'Dubrovačko-neretvanska županija', 59),
(531, 'HR', 'HR-20', 'Međimurska županija', 59),
(532, 'HR', 'HR-21', 'Grad Zagreb', 59),
(533, 'IN', 'AN', 'Andaman and Nicobar Islands', 106),
(534, 'IN', 'AP', 'Andhra Pradesh', 106),
(535, 'IN', 'AR', 'Arunachal Pradesh', 106),
(536, 'IN', 'AS', 'Assam', 106),
(537, 'IN', 'BR', 'Bihar', 106),
(538, 'IN', 'CH', 'Chandigarh', 106),
(539, 'IN', 'CT', 'Chhattisgarh', 106),
(540, 'IN', 'DN', 'Dadra and Nagar Haveli', 106),
(541, 'IN', 'DD', 'Daman and Diu', 106),
(542, 'IN', 'DL', 'Delhi', 106),
(543, 'IN', 'GA', 'Goa', 106),
(544, 'IN', 'GJ', 'Gujarat', 106),
(545, 'IN', 'HR', 'Haryana', 106),
(546, 'IN', 'HP', 'Himachal Pradesh', 106),
(547, 'IN', 'JK', 'Jammu and Kashmir', 106),
(548, 'IN', 'JH', 'Jharkhand', 106),
(549, 'IN', 'KA', 'Karnataka', 106),
(550, 'IN', 'KL', 'Kerala', 106),
(551, 'IN', 'LD', 'Lakshadweep', 106),
(552, 'IN', 'MP', 'Madhya Pradesh', 106),
(553, 'IN', 'MH', 'Maharashtra', 106),
(554, 'IN', 'MN', 'Manipur', 106),
(555, 'IN', 'ML', 'Meghalaya', 106),
(556, 'IN', 'MZ', 'Mizoram', 106),
(557, 'IN', 'NL', 'Nagaland', 106),
(558, 'IN', 'OR', 'Odisha', 106),
(559, 'IN', 'PY', 'Puducherry', 106),
(560, 'IN', 'PB', 'Punjab', 106),
(561, 'IN', 'RJ', 'Rajasthan', 106),
(562, 'IN', 'SK', 'Sikkim', 106),
(563, 'IN', 'TN', 'Tamil Nadu', 106),
(564, 'IN', 'TG', 'Telangana', 106),
(565, 'IN', 'TR', 'Tripura', 106),
(566, 'IN', 'UP', 'Uttar Pradesh', 106),
(567, 'IN', 'UT', 'Uttarakhand', 106),
(568, 'IN', 'WB', 'West Bengal', 106);

-- --------------------------------------------------------

--
-- Structure de la table `country_state_translations`
--

DROP TABLE IF EXISTS `country_state_translations`;
CREATE TABLE IF NOT EXISTS `country_state_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `default_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `country_state_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `country_state_translations_country_state_id_foreign` (`country_state_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8521 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `country_state_translations`
--

INSERT INTO `country_state_translations` (`id`, `locale`, `default_name`, `country_state_id`) VALUES
(6817, 'ar', 'ألاباما', 1),
(6818, 'ar', 'ألاسكا', 2),
(6819, 'ar', 'ساموا الأمريكية', 3),
(6820, 'ar', 'أريزونا', 4),
(6821, 'ar', 'أركنساس', 5),
(6822, 'ar', 'القوات المسلحة أفريقيا', 6),
(6823, 'ar', 'القوات المسلحة الأمريكية', 7),
(6824, 'ar', 'القوات المسلحة الكندية', 8),
(6825, 'ar', 'القوات المسلحة أوروبا', 9),
(6826, 'ar', 'القوات المسلحة الشرق الأوسط', 10),
(6827, 'ar', 'القوات المسلحة في المحيط الهادئ', 11),
(6828, 'ar', 'كاليفورنيا', 12),
(6829, 'ar', 'كولورادو', 13),
(6830, 'ar', 'كونيتيكت', 14),
(6831, 'ar', 'ديلاوير', 15),
(6832, 'ar', 'مقاطعة كولومبيا', 16),
(6833, 'ar', 'ولايات ميكرونيزيا الموحدة', 17),
(6834, 'ar', 'فلوريدا', 18),
(6835, 'ar', 'جورجيا', 19),
(6836, 'ar', 'غوام', 20),
(6837, 'ar', 'هاواي', 21),
(6838, 'ar', 'ايداهو', 22),
(6839, 'ar', 'إلينوي', 23),
(6840, 'ar', 'إنديانا', 24),
(6841, 'ar', 'أيوا', 25),
(6842, 'ar', 'كانساس', 26),
(6843, 'ar', 'كنتاكي', 27),
(6844, 'ar', 'لويزيانا', 28),
(6845, 'ar', 'مين', 29),
(6846, 'ar', 'جزر مارشال', 30),
(6847, 'ar', 'ماريلاند', 31),
(6848, 'ar', 'ماساتشوستس', 32),
(6849, 'ar', 'ميشيغان', 33),
(6850, 'ar', 'مينيسوتا', 34),
(6851, 'ar', 'ميسيسيبي', 35),
(6852, 'ar', 'ميسوري', 36),
(6853, 'ar', 'مونتانا', 37),
(6854, 'ar', 'نبراسكا', 38),
(6855, 'ar', 'نيفادا', 39),
(6856, 'ar', 'نيو هامبشاير', 40),
(6857, 'ar', 'نيو جيرسي', 41),
(6858, 'ar', 'المكسيك جديدة', 42),
(6859, 'ar', 'نيويورك', 43),
(6860, 'ar', 'شمال كارولينا', 44),
(6861, 'ar', 'شمال داكوتا', 45),
(6862, 'ar', 'جزر مريانا الشمالية', 46),
(6863, 'ar', 'أوهايو', 47),
(6864, 'ar', 'أوكلاهوما', 48),
(6865, 'ar', 'ولاية أوريغون', 49),
(6866, 'ar', 'بالاو', 50),
(6867, 'ar', 'بنسلفانيا', 51),
(6868, 'ar', 'بورتوريكو', 52),
(6869, 'ar', 'جزيرة رود', 53),
(6870, 'ar', 'كارولينا الجنوبية', 54),
(6871, 'ar', 'جنوب داكوتا', 55),
(6872, 'ar', 'تينيسي', 56),
(6873, 'ar', 'تكساس', 57),
(6874, 'ar', 'يوتا', 58),
(6875, 'ar', 'فيرمونت', 59),
(6876, 'ar', 'جزر فيرجن', 60),
(6877, 'ar', 'فرجينيا', 61),
(6878, 'ar', 'واشنطن', 62),
(6879, 'ar', 'فرجينيا الغربية', 63),
(6880, 'ar', 'ولاية ويسكونسن', 64),
(6881, 'ar', 'وايومنغ', 65),
(6882, 'ar', 'ألبرتا', 66),
(6883, 'ar', 'كولومبيا البريطانية', 67),
(6884, 'ar', 'مانيتوبا', 68),
(6885, 'ar', 'نيوفاوندلاند ولابرادور', 69),
(6886, 'ar', 'برونزيك جديد', 70),
(6887, 'ar', 'مقاطعة نفوفا سكوشيا', 71),
(6888, 'ar', 'الاقاليم الشمالية الغربية', 72),
(6889, 'ar', 'نونافوت', 73),
(6890, 'ar', 'أونتاريو', 74),
(6891, 'ar', 'جزيرة الأمير ادوارد', 75),
(6892, 'ar', 'كيبيك', 76),
(6893, 'ar', 'ساسكاتشوان', 77),
(6894, 'ar', 'إقليم يوكون', 78),
(6895, 'ar', 'Niedersachsen', 79),
(6896, 'ar', 'بادن فورتمبيرغ', 80),
(6897, 'ar', 'بايرن ميونيخ', 81),
(6898, 'ar', 'برلين', 82),
(6899, 'ar', 'براندنبورغ', 83),
(6900, 'ar', 'بريمن', 84),
(6901, 'ar', 'هامبورغ', 85),
(6902, 'ar', 'هيسن', 86),
(6903, 'ar', 'مكلنبورغ-فوربومرن', 87),
(6904, 'ar', 'نوردراين فيستفالن', 88),
(6905, 'ar', 'راينلاند-بفالز', 89),
(6906, 'ar', 'سارلاند', 90),
(6907, 'ar', 'ساكسن', 91),
(6908, 'ar', 'سكسونيا أنهالت', 92),
(6909, 'ar', 'شليسفيغ هولشتاين', 93),
(6910, 'ar', 'تورنغن', 94),
(6911, 'ar', 'فيينا', 95),
(6912, 'ar', 'النمسا السفلى', 96),
(6913, 'ar', 'النمسا العليا', 97),
(6914, 'ar', 'سالزبورغ', 98),
(6915, 'ar', 'Каринтия', 99),
(6916, 'ar', 'STEIERMARK', 100),
(6917, 'ar', 'تيرول', 101),
(6918, 'ar', 'بورغنلاند', 102),
(6919, 'ar', 'فورارلبرغ', 103),
(6920, 'ar', 'أرجاو', 104),
(6921, 'ar', 'Appenzell Innerrhoden', 105),
(6922, 'ar', 'أبنزل أوسيرهودن', 106),
(6923, 'ar', 'برن', 107),
(6924, 'ar', 'كانتون ريف بازل', 108),
(6925, 'ar', 'بازل شتات', 109),
(6926, 'ar', 'فرايبورغ', 110),
(6927, 'ar', 'Genf', 111),
(6928, 'ar', 'جلاروس', 112),
(6929, 'ar', 'غراوبوندن', 113),
(6930, 'ar', 'العصر الجوارسي أو الجوري', 114),
(6931, 'ar', 'لوزيرن', 115),
(6932, 'ar', 'في Neuenburg', 116),
(6933, 'ar', 'نيدوالدن', 117),
(6934, 'ar', 'أوبوالدن', 118),
(6935, 'ar', 'سانت غالن', 119),
(6936, 'ar', 'شافهاوزن', 120),
(6937, 'ar', 'سولوتورن', 121),
(6938, 'ar', 'شفيتس', 122),
(6939, 'ar', 'ثورجو', 123),
(6940, 'ar', 'تيتشينو', 124),
(6941, 'ar', 'أوري', 125),
(6942, 'ar', 'وادت', 126),
(6943, 'ar', 'اليس', 127),
(6944, 'ar', 'زوغ', 128),
(6945, 'ar', 'زيورخ', 129),
(6946, 'ar', 'Corunha', 130),
(6947, 'ar', 'ألافا', 131),
(6948, 'ar', 'الباسيتي', 132),
(6949, 'ar', 'اليكانتي', 133),
(6950, 'ar', 'الميريا', 134),
(6951, 'ar', 'أستورياس', 135),
(6952, 'ar', 'أفيلا', 136),
(6953, 'ar', 'بطليوس', 137),
(6954, 'ar', 'البليار', 138),
(6955, 'ar', 'برشلونة', 139),
(6956, 'ar', 'برغش', 140),
(6957, 'ar', 'كاسيريس', 141),
(6958, 'ar', 'كاديز', 142),
(6959, 'ar', 'كانتابريا', 143),
(6960, 'ar', 'كاستيلون', 144),
(6961, 'ar', 'سبتة', 145),
(6962, 'ar', 'سيوداد ريال', 146),
(6963, 'ar', 'قرطبة', 147),
(6964, 'ar', 'كوينكا', 148),
(6965, 'ar', 'جيرونا', 149),
(6966, 'ar', 'غرناطة', 150),
(6967, 'ar', 'غوادالاخارا', 151),
(6968, 'ar', 'بجويبوزكوا', 152),
(6969, 'ar', 'هويلفا', 153),
(6970, 'ar', 'هويسكا', 154),
(6971, 'ar', 'خاين', 155),
(6972, 'ar', 'لاريوخا', 156),
(6973, 'ar', 'لاس بالماس', 157),
(6974, 'ar', 'ليون', 158),
(6975, 'ar', 'يدا', 159),
(6976, 'ar', 'لوغو', 160),
(6977, 'ar', 'مدريد', 161),
(6978, 'ar', 'ملقة', 162),
(6979, 'ar', 'مليلية', 163),
(6980, 'ar', 'مورسيا', 164),
(6981, 'ar', 'نافارا', 165),
(6982, 'ar', 'أورينس', 166),
(6983, 'ar', 'بلنسية', 167),
(6984, 'ar', 'بونتيفيدرا', 168),
(6985, 'ar', 'سالامانكا', 169),
(6986, 'ar', 'سانتا كروز دي تينيريفي', 170),
(6987, 'ar', 'سيغوفيا', 171),
(6988, 'ar', 'اشبيلية', 172),
(6989, 'ar', 'سوريا', 173),
(6990, 'ar', 'تاراغونا', 174),
(6991, 'ar', 'تيرويل', 175),
(6992, 'ar', 'توليدو', 176),
(6993, 'ar', 'فالنسيا', 177),
(6994, 'ar', 'بلد الوليد', 178),
(6995, 'ar', 'فيزكايا', 179),
(6996, 'ar', 'زامورا', 180),
(6997, 'ar', 'سرقسطة', 181),
(6998, 'ar', 'عين', 182),
(6999, 'ar', 'أيسن', 183),
(7000, 'ar', 'اليي', 184),
(7001, 'ar', 'ألب البروفنس العليا', 185),
(7002, 'ar', 'أوتس ألب', 186),
(7003, 'ar', 'ألب ماريتيم', 187),
(7004, 'ar', 'ARDECHE', 188),
(7005, 'ar', 'Ardennes', 189),
(7006, 'ar', 'آردن', 190),
(7007, 'ar', 'أوب', 191),
(7008, 'ar', 'اود', 192),
(7009, 'ar', 'أفيرون', 193),
(7010, 'ar', 'بوكاس دو رون', 194),
(7011, 'ar', 'كالفادوس', 195),
(7012, 'ar', 'كانتال', 196),
(7013, 'ar', 'شارانت', 197),
(7014, 'ar', 'سيين إت مارن', 198),
(7015, 'ar', 'شير', 199),
(7016, 'ar', 'كوريز', 200),
(7017, 'ar', 'سود كورس-دو-', 201),
(7018, 'ar', 'هوت كورس', 202),
(7019, 'ar', 'كوستا دوركوريز', 203),
(7020, 'ar', 'كوتس دورمور', 204),
(7021, 'ar', 'كروز', 205),
(7022, 'ar', 'دوردوني', 206),
(7023, 'ar', 'دوبس', 207),
(7024, 'ar', 'DrômeFinistère', 208),
(7025, 'ar', 'أور', 209),
(7026, 'ar', 'أور ولوار', 210),
(7027, 'ar', 'فينيستير', 211),
(7028, 'ar', 'جارد', 212),
(7029, 'ar', 'هوت غارون', 213),
(7030, 'ar', 'الخيام', 214),
(7031, 'ar', 'جيروند', 215),
(7032, 'ar', 'هيرولت', 216),
(7033, 'ar', 'إيل وفيلان', 217),
(7034, 'ar', 'إندر', 218),
(7035, 'ar', 'أندر ولوار', 219),
(7036, 'ar', 'إيسر', 220),
(7037, 'ar', 'العصر الجوارسي أو الجوري', 221),
(7038, 'ar', 'اندز', 222),
(7039, 'ar', 'لوار وشير', 223),
(7040, 'ar', 'لوار', 224),
(7041, 'ar', 'هوت-لوار', 225),
(7042, 'ar', 'وار أتلانتيك', 226),
(7043, 'ar', 'لورا', 227),
(7044, 'ar', 'كثيرا', 228),
(7045, 'ar', 'الكثير غارون', 229),
(7046, 'ar', 'لوزر', 230),
(7047, 'ar', 'مين-إي-لوار', 231),
(7048, 'ar', 'المانش', 232),
(7049, 'ar', 'مارن', 233),
(7050, 'ar', 'هوت مارن', 234),
(7051, 'ar', 'مايين', 235),
(7052, 'ar', 'مورت وموزيل', 236),
(7053, 'ar', 'ميوز', 237),
(7054, 'ar', 'موربيهان', 238),
(7055, 'ar', 'موسيل', 239),
(7056, 'ar', 'نيفر', 240),
(7057, 'ar', 'نورد', 241),
(7058, 'ar', 'إيل دو فرانس', 242),
(7059, 'ar', 'أورن', 243),
(7060, 'ar', 'با-دو-كاليه', 244),
(7061, 'ar', 'بوي دي دوم', 245),
(7062, 'ar', 'البرانيس ​​الأطلسية', 246),
(7063, 'ar', 'أوتس-بيرينيهs', 247),
(7064, 'ar', 'بيرينيه-أورينتال', 248),
(7065, 'ar', 'بس رين', 249),
(7066, 'ar', 'أوت رين', 250),
(7067, 'ar', 'رون [3]', 251),
(7068, 'ar', 'هوت-سون', 252),
(7069, 'ar', 'سون ولوار', 253),
(7070, 'ar', 'سارت', 254),
(7071, 'ar', 'سافوا', 255),
(7072, 'ar', 'هاوت سافوي', 256),
(7073, 'ar', 'باريس', 257),
(7074, 'ar', 'سين البحرية', 258),
(7075, 'ar', 'سيين إت مارن', 259),
(7076, 'ar', 'إيفلين', 260),
(7077, 'ar', 'دوكس سفرس', 261),
(7078, 'ar', 'السوم', 262),
(7079, 'ar', 'تارن', 263),
(7080, 'ar', 'تارن وغارون', 264),
(7081, 'ar', 'فار', 265),
(7082, 'ar', 'فوكلوز', 266),
(7083, 'ar', 'تارن', 267),
(7084, 'ar', 'فيين', 268),
(7085, 'ar', 'هوت فيين', 269),
(7086, 'ar', 'الفوج', 270),
(7087, 'ar', 'يون', 271),
(7088, 'ar', 'تيريتوير-دي-بلفور', 272),
(7089, 'ar', 'إيسون', 273),
(7090, 'ar', 'هوت دو سين', 274),
(7091, 'ar', 'سين سان دوني', 275),
(7092, 'ar', 'فال دو مارن', 276),
(7093, 'ar', 'فال دواز', 277),
(7094, 'ar', 'ألبا', 278),
(7095, 'ar', 'اراد', 279),
(7096, 'ar', 'ARGES', 280),
(7097, 'ar', 'باكاو', 281),
(7098, 'ar', 'بيهور', 282),
(7099, 'ar', 'بيستريتا ناسود', 283),
(7100, 'ar', 'بوتوساني', 284),
(7101, 'ar', 'براشوف', 285),
(7102, 'ar', 'برايلا', 286),
(7103, 'ar', 'بوخارست', 287),
(7104, 'ar', 'بوزاو', 288),
(7105, 'ar', 'كاراس سيفيرين', 289),
(7106, 'ar', 'كالاراسي', 290),
(7107, 'ar', 'كلوج', 291),
(7108, 'ar', 'كونستانتا', 292),
(7109, 'ar', 'كوفاسنا', 293),
(7110, 'ar', 'دامبوفيتا', 294),
(7111, 'ar', 'دولج', 295),
(7112, 'ar', 'جالاتي', 296),
(7113, 'ar', 'Giurgiu', 297),
(7114, 'ar', 'غيورغيو', 298),
(7115, 'ar', 'هارغيتا', 299),
(7116, 'ar', 'هونيدوارا', 300),
(7117, 'ar', 'ايالوميتا', 301),
(7118, 'ar', 'ياشي', 302),
(7119, 'ar', 'إيلفوف', 303),
(7120, 'ar', 'مارامريس', 304),
(7121, 'ar', 'MEHEDINTI', 305),
(7122, 'ar', 'موريس', 306),
(7123, 'ar', 'نيامتس', 307),
(7124, 'ar', 'أولت', 308),
(7125, 'ar', 'براهوفا', 309),
(7126, 'ar', 'ساتو ماري', 310),
(7127, 'ar', 'سالاج', 311),
(7128, 'ar', 'سيبيو', 312),
(7129, 'ar', 'سوسيفا', 313),
(7130, 'ar', 'تيليورمان', 314),
(7131, 'ar', 'تيم هو', 315),
(7132, 'ar', 'تولسيا', 316),
(7133, 'ar', 'فاسلوي', 317),
(7134, 'ar', 'فالسيا', 318),
(7135, 'ar', 'فرانتشا', 319),
(7136, 'ar', 'Lappi', 320),
(7137, 'ar', 'Pohjois-Pohjanmaa', 321),
(7138, 'ar', 'كاينو', 322),
(7139, 'ar', 'Pohjois-كارجالا', 323),
(7140, 'ar', 'Pohjois-سافو', 324),
(7141, 'ar', 'Etelä-سافو', 325),
(7142, 'ar', 'Etelä-Pohjanmaa', 326),
(7143, 'ar', 'Pohjanmaa', 327),
(7144, 'ar', 'بيركنما', 328),
(7145, 'ar', 'ساتا كونتا', 329),
(7146, 'ar', 'كسكي-Pohjanmaa', 330),
(7147, 'ar', 'كسكي-سومي', 331),
(7148, 'ar', 'Varsinais-سومي', 332),
(7149, 'ar', 'Etelä-كارجالا', 333),
(7150, 'ar', 'Päijät-Häme', 334),
(7151, 'ar', 'كانتا-HAME', 335),
(7152, 'ar', 'أوسيما', 336),
(7153, 'ar', 'أوسيما', 337),
(7154, 'ar', 'كومنلاكسو', 338),
(7155, 'ar', 'Ahvenanmaa', 339),
(7156, 'ar', 'Harjumaa', 340),
(7157, 'ar', 'هيوما', 341),
(7158, 'ar', 'المؤسسة الدولية للتنمية فيروما', 342),
(7159, 'ar', 'جوغفما', 343),
(7160, 'ar', 'يارفا', 344),
(7161, 'ar', 'انيما', 345),
(7162, 'ar', 'اني فيريوما', 346),
(7163, 'ar', 'بولفاما', 347),
(7164, 'ar', 'بارنوما', 348),
(7165, 'ar', 'Raplamaa', 349),
(7166, 'ar', 'Saaremaa', 350),
(7167, 'ar', 'Tartumaa', 351),
(7168, 'ar', 'Valgamaa', 352),
(7169, 'ar', 'Viljandimaa', 353),
(7170, 'ar', 'روايات Salacgr novvas', 354),
(7171, 'ar', 'داوجافبيلس', 355),
(7172, 'ar', 'يلغافا', 356),
(7173, 'ar', 'يكاب', 357),
(7174, 'ar', 'يورمال', 358),
(7175, 'ar', 'يابايا', 359),
(7176, 'ar', 'ليباج أبريس', 360),
(7177, 'ar', 'ريزكن', 361),
(7178, 'ar', 'ريغا', 362),
(7179, 'ar', 'مقاطعة ريغا', 363),
(7180, 'ar', 'فالميرا', 364),
(7181, 'ar', 'فنتسبيلز', 365),
(7182, 'ar', 'روايات Aglonas', 366),
(7183, 'ar', 'Aizkraukles novads', 367),
(7184, 'ar', 'Aizkraukles novads', 368),
(7185, 'ar', 'Aknīstes novads', 369),
(7186, 'ar', 'Alojas novads', 370),
(7187, 'ar', 'روايات Alsungas', 371),
(7188, 'ar', 'ألكسنس أبريز', 372),
(7189, 'ar', 'روايات أماتاس', 373),
(7190, 'ar', 'قرود الروايات', 374),
(7191, 'ar', 'روايات أوسيس', 375),
(7192, 'ar', 'بابيت الروايات', 376),
(7193, 'ar', 'Baldones الروايات', 377),
(7194, 'ar', 'بالتينافاس الروايات', 378),
(7195, 'ar', 'روايات بالفو', 379),
(7196, 'ar', 'Bauskas الروايات', 380),
(7197, 'ar', 'Beverīnas novads', 381),
(7198, 'ar', 'Novads Brocēnu', 382),
(7199, 'ar', 'Novads Burtnieku', 383),
(7200, 'ar', 'Carnikavas novads', 384),
(7201, 'ar', 'Cesvaines novads', 385),
(7202, 'ar', 'Ciblas novads', 386),
(7203, 'ar', 'تسو أبريس', 387),
(7204, 'ar', 'Dagdas novads', 388),
(7205, 'ar', 'Daugavpils novads', 389),
(7206, 'ar', 'روايات دوبيليس', 390),
(7207, 'ar', 'ديربيس الروايات', 391),
(7208, 'ar', 'ديربيس الروايات', 392),
(7209, 'ar', 'يشرك الروايات', 393),
(7210, 'ar', 'Garkalnes novads', 394),
(7211, 'ar', 'Grobiņas novads', 395),
(7212, 'ar', 'غولبينيس الروايات', 396),
(7213, 'ar', 'إيكافاس روايات', 397),
(7214, 'ar', 'Ikškiles novads', 398),
(7215, 'ar', 'Ilūkstes novads', 399),
(7216, 'ar', 'روايات Inčukalna', 400),
(7217, 'ar', 'Jaunjelgavas novads', 401),
(7218, 'ar', 'Jaunpiebalgas novads', 402),
(7219, 'ar', 'روايات Jaunpiebalgas', 403),
(7220, 'ar', 'Jelgavas novads', 404),
(7221, 'ar', 'جيكابيلس أبريز', 405),
(7222, 'ar', 'روايات كاندافاس', 406),
(7223, 'ar', 'Kokneses الروايات', 407),
(7224, 'ar', 'Krimuldas novads', 408),
(7225, 'ar', 'Krustpils الروايات', 409),
(7226, 'ar', 'Krāslavas Apriņķis', 410),
(7227, 'ar', 'كولدوغاس أبريز', 411),
(7228, 'ar', 'Kārsavas novads', 412),
(7229, 'ar', 'روايات ييلفاريس', 413),
(7230, 'ar', 'ليمباو أبريز', 414),
(7231, 'ar', 'روايات لباناس', 415),
(7232, 'ar', 'روايات لودزاس', 416),
(7233, 'ar', 'مقاطعة ليجاتني', 417),
(7234, 'ar', 'مقاطعة ليفاني', 418),
(7235, 'ar', 'مادونا روايات', 419),
(7236, 'ar', 'Mazsalacas novads', 420),
(7237, 'ar', 'روايات مالبلز', 421),
(7238, 'ar', 'Mārupes novads', 422),
(7239, 'ar', 'نوفاو نوكشنو', 423),
(7240, 'ar', 'روايات نيريتاس', 424),
(7241, 'ar', 'روايات نيكاس', 425),
(7242, 'ar', 'أغنام الروايات', 426),
(7243, 'ar', 'أولينيس الروايات', 427),
(7244, 'ar', 'روايات Ozolnieku', 428),
(7245, 'ar', 'بريسيو أبرييس', 429),
(7246, 'ar', 'Priekules الروايات', 430),
(7247, 'ar', 'كوندادو دي بريكوي', 431),
(7248, 'ar', 'Pärgaujas novads', 432),
(7249, 'ar', 'روايات بافيلوستاس', 433),
(7250, 'ar', 'بلافيناس مقاطعة', 434),
(7251, 'ar', 'روناس روايات', 435),
(7252, 'ar', 'Riebiņu novads', 436),
(7253, 'ar', 'روجاس روايات', 437),
(7254, 'ar', 'Novads روباو', 438),
(7255, 'ar', 'روكافاس روايات', 439),
(7256, 'ar', 'روغاجو روايات', 440),
(7257, 'ar', 'رندلس الروايات', 441),
(7258, 'ar', 'Radzeknes novads', 442),
(7259, 'ar', 'Rūjienas novads', 443),
(7260, 'ar', 'بلدية سالاسغريفا', 444),
(7261, 'ar', 'روايات سالاس', 445),
(7262, 'ar', 'Salaspils novads', 446),
(7263, 'ar', 'روايات سالدوس', 447),
(7264, 'ar', 'Novuls Saulkrastu', 448),
(7265, 'ar', 'سيغولداس روايات', 449),
(7266, 'ar', 'Skrundas novads', 450),
(7267, 'ar', 'مقاطعة Skrīveri', 451),
(7268, 'ar', 'يبتسم الروايات', 452),
(7269, 'ar', 'روايات Stopiņu', 453),
(7270, 'ar', 'روايات Stren novu', 454),
(7271, 'ar', 'سجاس روايات', 455),
(7272, 'ar', 'روايات تالسو', 456),
(7273, 'ar', 'توكوما الروايات', 457),
(7274, 'ar', 'Tērvetes novads', 458),
(7275, 'ar', 'Vaiņodes novads', 459),
(7276, 'ar', 'فالكاس الروايات', 460),
(7277, 'ar', 'فالميراس الروايات', 461),
(7278, 'ar', 'مقاطعة فاكلاني', 462),
(7279, 'ar', 'Vecpiebalgas novads', 463),
(7280, 'ar', 'روايات Vecumnieku', 464),
(7281, 'ar', 'فنتسبيلس الروايات', 465),
(7282, 'ar', 'Viesītes Novads', 466),
(7283, 'ar', 'Viļakas novads', 467),
(7284, 'ar', 'روايات فيناو', 468),
(7285, 'ar', 'Vārkavas novads', 469),
(7286, 'ar', 'روايات زيلوبس', 470),
(7287, 'ar', 'مقاطعة أدازي', 471),
(7288, 'ar', 'مقاطعة Erglu', 472),
(7289, 'ar', 'مقاطعة كيغمس', 473),
(7290, 'ar', 'مقاطعة كيكافا', 474),
(7291, 'ar', 'Alytaus Apskritis', 475),
(7292, 'ar', 'كاونو ابكريتيس', 476),
(7293, 'ar', 'Klaipėdos apskritis', 477),
(7294, 'ar', 'Marijampol\'s apskritis', 478),
(7295, 'ar', 'Panevėžio apskritis', 479),
(7296, 'ar', 'uliaulių apskritis', 480),
(7297, 'ar', 'Taurag\'s apskritis', 481),
(7298, 'ar', 'Telšių apskritis', 482),
(7299, 'ar', 'Utenos apskritis', 483),
(7300, 'ar', 'فيلنياوس ابكريتيس', 484),
(7301, 'ar', 'فدان', 485),
(7302, 'ar', 'ألاغواس', 486),
(7303, 'ar', 'أمابا', 487),
(7304, 'ar', 'أمازوناس', 488),
(7305, 'ar', 'باهيا', 489),
(7306, 'ar', 'سيارا', 490),
(7307, 'ar', 'إسبيريتو سانتو', 491),
(7308, 'ar', 'غوياس', 492),
(7309, 'ar', 'مارانهاو', 493),
(7310, 'ar', 'ماتو جروسو', 494),
(7311, 'ar', 'ماتو جروسو دو سول', 495),
(7312, 'ar', 'ميناس جريس', 496),
(7313, 'ar', 'بارا', 497),
(7314, 'ar', 'بارايبا', 498),
(7315, 'ar', 'بارانا', 499),
(7316, 'ar', 'بيرنامبوكو', 500),
(7317, 'ar', 'بياوي', 501),
(7318, 'ar', 'ريو دي جانيرو', 502),
(7319, 'ar', 'ريو غراندي دو نورتي', 503),
(7320, 'ar', 'ريو غراندي دو سول', 504),
(7321, 'ar', 'روندونيا', 505),
(7322, 'ar', 'رورايما', 506),
(7323, 'ar', 'سانتا كاتارينا', 507),
(7324, 'ar', 'ساو باولو', 508),
(7325, 'ar', 'سيرغيبي', 509),
(7326, 'ar', 'توكانتينز', 510),
(7327, 'ar', 'وفي مقاطعة الاتحادية', 511),
(7328, 'ar', 'Zagrebačka زوبانيا', 512),
(7329, 'ar', 'Krapinsko-zagorska زوبانيا', 513),
(7330, 'ar', 'Sisačko-moslavačka زوبانيا', 514),
(7331, 'ar', 'كارلوفيتش شوبانيا', 515),
(7332, 'ar', 'فارادينسكا زوبانيجا', 516),
(7333, 'ar', 'Koprivničko-križevačka زوبانيجا', 517),
(7334, 'ar', 'بيلوفارسكو-بيلوجورسكا', 518),
(7335, 'ar', 'بريمورسكو غورانسكا سوبانيا', 519),
(7336, 'ar', 'ليكو سينيسكا زوبانيا', 520),
(7337, 'ar', 'Virovitičko-podravska زوبانيا', 521),
(7338, 'ar', 'Požeško-slavonska županija', 522),
(7339, 'ar', 'Brodsko-posavska županija', 523),
(7340, 'ar', 'زادارسكا زوبانيجا', 524),
(7341, 'ar', 'Osječko-baranjska županija', 525),
(7342, 'ar', 'شيبنسكو-كنينسكا سوبانيا', 526),
(7343, 'ar', 'Virovitičko-podravska زوبانيا', 527),
(7344, 'ar', 'Splitsko-dalmatinska زوبانيا', 528),
(7345, 'ar', 'Istarska زوبانيا', 529),
(7346, 'ar', 'Dubrovačko-neretvanska زوبانيا', 530),
(7347, 'ar', 'Međimurska زوبانيا', 531),
(7348, 'ar', 'غراد زغرب', 532),
(7349, 'ar', 'جزر أندامان ونيكوبار', 533),
(7350, 'ar', 'ولاية اندرا براديش', 534),
(7351, 'ar', 'اروناتشال براديش', 535),
(7352, 'ar', 'أسام', 536),
(7353, 'ar', 'بيهار', 537),
(7354, 'ar', 'شانديغار', 538),
(7355, 'ar', 'تشهاتيسجاره', 539),
(7356, 'ar', 'دادرا ونجار هافيلي', 540),
(7357, 'ar', 'دامان وديو', 541),
(7358, 'ar', 'دلهي', 542),
(7359, 'ar', 'غوا', 543),
(7360, 'ar', 'غوجارات', 544),
(7361, 'ar', 'هاريانا', 545),
(7362, 'ar', 'هيماشال براديش', 546),
(7363, 'ar', 'جامو وكشمير', 547),
(7364, 'ar', 'جهارخاند', 548),
(7365, 'ar', 'كارناتاكا', 549),
(7366, 'ar', 'ولاية كيرالا', 550),
(7367, 'ar', 'اكشادويب', 551),
(7368, 'ar', 'ماديا براديش', 552),
(7369, 'ar', 'ماهاراشترا', 553),
(7370, 'ar', 'مانيبور', 554),
(7371, 'ar', 'ميغالايا', 555),
(7372, 'ar', 'ميزورام', 556),
(7373, 'ar', 'ناجالاند', 557),
(7374, 'ar', 'أوديشا', 558),
(7375, 'ar', 'بودوتشيري', 559),
(7376, 'ar', 'البنجاب', 560),
(7377, 'ar', 'راجستان', 561),
(7378, 'ar', 'سيكيم', 562),
(7379, 'ar', 'تاميل نادو', 563),
(7380, 'ar', 'تيلانجانا', 564),
(7381, 'ar', 'تريبورا', 565),
(7382, 'ar', 'ولاية اوتار براديش', 566),
(7383, 'ar', 'أوتارانتشال', 567),
(7384, 'ar', 'البنغال الغربية', 568),
(7385, 'fa', 'آلاباما', 1),
(7386, 'fa', 'آلاسکا', 2),
(7387, 'fa', 'ساموآ آمریکایی', 3),
(7388, 'fa', 'آریزونا', 4),
(7389, 'fa', 'آرکانزاس', 5),
(7390, 'fa', 'نیروهای مسلح آفریقا', 6),
(7391, 'fa', 'Armed Forces America', 7),
(7392, 'fa', 'نیروهای مسلح کانادا', 8),
(7393, 'fa', 'نیروهای مسلح اروپا', 9),
(7394, 'fa', 'نیروهای مسلح خاورمیانه', 10),
(7395, 'fa', 'نیروهای مسلح اقیانوس آرام', 11),
(7396, 'fa', 'کالیفرنیا', 12),
(7397, 'fa', 'کلرادو', 13),
(7398, 'fa', 'کانکتیکات', 14),
(7399, 'fa', 'دلاور', 15),
(7400, 'fa', 'منطقه کلمبیا', 16),
(7401, 'fa', 'ایالات فدرال میکرونزی', 17),
(7402, 'fa', 'فلوریدا', 18),
(7403, 'fa', 'جورجیا', 19),
(7404, 'fa', 'گوام', 20),
(7405, 'fa', 'هاوایی', 21),
(7406, 'fa', 'آیداهو', 22),
(7407, 'fa', 'ایلینویز', 23),
(7408, 'fa', 'ایندیانا', 24),
(7409, 'fa', 'آیووا', 25),
(7410, 'fa', 'کانزاس', 26),
(7411, 'fa', 'کنتاکی', 27),
(7412, 'fa', 'لوئیزیانا', 28),
(7413, 'fa', 'ماین', 29),
(7414, 'fa', 'مای', 30),
(7415, 'fa', 'مریلند', 31),
(7416, 'fa', ' ', 32),
(7417, 'fa', 'میشیگان', 33),
(7418, 'fa', 'مینه سوتا', 34),
(7419, 'fa', 'می سی سی پی', 35),
(7420, 'fa', 'میسوری', 36),
(7421, 'fa', 'مونتانا', 37),
(7422, 'fa', 'نبراسکا', 38),
(7423, 'fa', 'نواد', 39),
(7424, 'fa', 'نیوهمپشایر', 40),
(7425, 'fa', 'نیوجرسی', 41),
(7426, 'fa', 'نیومکزیکو', 42),
(7427, 'fa', 'نیویورک', 43),
(7428, 'fa', 'کارولینای شمالی', 44),
(7429, 'fa', 'داکوتای شمالی', 45),
(7430, 'fa', 'جزایر ماریانای شمالی', 46),
(7431, 'fa', 'اوهایو', 47),
(7432, 'fa', 'اوکلاهما', 48),
(7433, 'fa', 'اورگان', 49),
(7434, 'fa', 'پالائو', 50),
(7435, 'fa', 'پنسیلوانیا', 51),
(7436, 'fa', 'پورتوریکو', 52),
(7437, 'fa', 'رود آیلند', 53),
(7438, 'fa', 'کارولینای جنوبی', 54),
(7439, 'fa', 'داکوتای جنوبی', 55),
(7440, 'fa', 'تنسی', 56),
(7441, 'fa', 'تگزاس', 57),
(7442, 'fa', 'یوتا', 58),
(7443, 'fa', 'ورمونت', 59),
(7444, 'fa', 'جزایر ویرجین', 60),
(7445, 'fa', 'ویرجینیا', 61),
(7446, 'fa', 'واشنگتن', 62),
(7447, 'fa', 'ویرجینیای غربی', 63),
(7448, 'fa', 'ویسکانسین', 64),
(7449, 'fa', 'وایومینگ', 65),
(7450, 'fa', 'آلبرتا', 66),
(7451, 'fa', 'بریتیش کلمبیا', 67),
(7452, 'fa', 'مانیتوبا', 68),
(7453, 'fa', 'نیوفاندلند و لابرادور', 69),
(7454, 'fa', 'نیوبرانزویک', 70),
(7455, 'fa', 'نوا اسکوشیا', 71),
(7456, 'fa', 'سرزمینهای شمال غربی', 72),
(7457, 'fa', 'نوناووت', 73),
(7458, 'fa', 'انتاریو', 74),
(7459, 'fa', 'جزیره پرنس ادوارد', 75),
(7460, 'fa', 'کبک', 76),
(7461, 'fa', 'ساسکاتچوان', 77),
(7462, 'fa', 'قلمرو یوکان', 78),
(7463, 'fa', 'نیدرزاکسن', 79),
(7464, 'fa', 'بادن-وورتمبرگ', 80),
(7465, 'fa', 'بایرن', 81),
(7466, 'fa', 'برلین', 82),
(7467, 'fa', 'براندنبورگ', 83),
(7468, 'fa', 'برمن', 84),
(7469, 'fa', 'هامبور', 85),
(7470, 'fa', 'هسن', 86),
(7471, 'fa', 'مکلنبورگ-وورپومرن', 87),
(7472, 'fa', 'نوردراین-وستفالن', 88),
(7473, 'fa', 'راینلاند-پلاتینات', 89),
(7474, 'fa', 'سارلند', 90),
(7475, 'fa', 'ساچسن', 91),
(7476, 'fa', 'ساچسن-آنهالت', 92),
(7477, 'fa', 'شلسویگ-هولشتاین', 93),
(7478, 'fa', 'تورینگی', 94),
(7479, 'fa', 'وین', 95),
(7480, 'fa', 'اتریش پایین', 96),
(7481, 'fa', 'اتریش فوقانی', 97),
(7482, 'fa', 'سالزبورگ', 98),
(7483, 'fa', 'کارنتا', 99),
(7484, 'fa', 'Steiermar', 100),
(7485, 'fa', 'تیرول', 101),
(7486, 'fa', 'بورگنلن', 102),
(7487, 'fa', 'Vorarlber', 103),
(7488, 'fa', 'آرگ', 104),
(7489, 'fa', '', 105),
(7490, 'fa', 'اپنزلسرهودن', 106),
(7491, 'fa', 'بر', 107),
(7492, 'fa', 'بازل-لندشفت', 108),
(7493, 'fa', 'بازل استاد', 109),
(7494, 'fa', 'فرایبورگ', 110),
(7495, 'fa', 'گنف', 111),
(7496, 'fa', 'گلاروس', 112),
(7497, 'fa', 'Graubünde', 113),
(7498, 'fa', 'ژورا', 114),
(7499, 'fa', 'لوزرن', 115),
(7500, 'fa', 'نوینبور', 116),
(7501, 'fa', 'نیدالد', 117),
(7502, 'fa', 'اوبولدن', 118),
(7503, 'fa', 'سنت گالن', 119),
(7504, 'fa', 'شافهاوز', 120),
(7505, 'fa', 'سولوتور', 121),
(7506, 'fa', 'شووی', 122),
(7507, 'fa', 'تورگاو', 123),
(7508, 'fa', 'تسسی', 124),
(7509, 'fa', 'اوری', 125),
(7510, 'fa', 'وادت', 126),
(7511, 'fa', 'والی', 127),
(7512, 'fa', 'ز', 128),
(7513, 'fa', 'زوریخ', 129),
(7514, 'fa', 'کورونا', 130),
(7515, 'fa', 'آلاوا', 131),
(7516, 'fa', 'آلبوم', 132),
(7517, 'fa', 'آلیکانت', 133),
(7518, 'fa', 'آلمریا', 134),
(7519, 'fa', 'آستوریا', 135),
(7520, 'fa', 'آویلا', 136),
(7521, 'fa', 'باداژوز', 137),
(7522, 'fa', 'ضرب و شتم', 138),
(7523, 'fa', 'بارسلون', 139),
(7524, 'fa', 'بورگو', 140),
(7525, 'fa', 'کاسر', 141),
(7526, 'fa', 'کادی', 142),
(7527, 'fa', 'کانتابریا', 143),
(7528, 'fa', 'کاستلون', 144),
(7529, 'fa', 'سوت', 145),
(7530, 'fa', 'سیوداد واقعی', 146),
(7531, 'fa', 'کوردوب', 147),
(7532, 'fa', 'Cuenc', 148),
(7533, 'fa', 'جیرون', 149),
(7534, 'fa', 'گراناد', 150),
(7535, 'fa', 'گوادالاجار', 151),
(7536, 'fa', 'Guipuzcoa', 152),
(7537, 'fa', 'هولوا', 153),
(7538, 'fa', 'هوسک', 154),
(7539, 'fa', 'جی', 155),
(7540, 'fa', 'لا ریوجا', 156),
(7541, 'fa', 'لاس پالماس', 157),
(7542, 'fa', 'لئو', 158),
(7543, 'fa', 'Lleid', 159),
(7544, 'fa', 'لوگ', 160),
(7545, 'fa', 'مادری', 161),
(7546, 'fa', 'مالاگ', 162),
(7547, 'fa', 'ملیلی', 163),
(7548, 'fa', 'مورسیا', 164),
(7549, 'fa', 'ناوار', 165),
(7550, 'fa', 'اورنس', 166),
(7551, 'fa', 'پالنسی', 167),
(7552, 'fa', 'پونتوودر', 168),
(7553, 'fa', 'سالامانک', 169),
(7554, 'fa', 'سانتا کروز د تنریفه', 170),
(7555, 'fa', 'سوگویا', 171),
(7556, 'fa', 'سوی', 172),
(7557, 'fa', 'سوریا', 173),
(7558, 'fa', 'تاراگونا', 174),
(7559, 'fa', 'ترئو', 175),
(7560, 'fa', 'تولدو', 176),
(7561, 'fa', 'والنسیا', 177),
(7562, 'fa', 'والادولی', 178),
(7563, 'fa', 'ویزکایا', 179),
(7564, 'fa', 'زامور', 180),
(7565, 'fa', 'ساراگوز', 181),
(7566, 'fa', 'عی', 182),
(7567, 'fa', 'آیز', 183),
(7568, 'fa', 'آلی', 184),
(7569, 'fa', 'آلپ-دو-هاوت-پرووانس', 185),
(7570, 'fa', 'هاوتس آلپ', 186),
(7571, 'fa', 'Alpes-Maritime', 187),
(7572, 'fa', 'اردچه', 188),
(7573, 'fa', 'آرد', 189),
(7574, 'fa', 'محاصر', 190),
(7575, 'fa', 'آبه', 191),
(7576, 'fa', 'Aud', 192),
(7577, 'fa', 'آویرون', 193),
(7578, 'fa', 'BOCAS DO Rhône', 194),
(7579, 'fa', 'نوعی عرق', 195),
(7580, 'fa', 'کانتینال', 196),
(7581, 'fa', 'چارنت', 197),
(7582, 'fa', 'چارنت-دریایی', 198),
(7583, 'fa', 'چ', 199),
(7584, 'fa', 'کور', 200),
(7585, 'fa', 'کرس دو ساد', 201),
(7586, 'fa', 'هاوت کورس', 202),
(7587, 'fa', 'کوستا دورکرز', 203),
(7588, 'fa', 'تخت دارمور', 204),
(7589, 'fa', 'درهم', 205),
(7590, 'fa', 'دوردگن', 206),
(7591, 'fa', 'دوب', 207),
(7592, 'fa', 'تعریف اول', 208),
(7593, 'fa', 'یور', 209),
(7594, 'fa', 'Eure-et-Loi', 210),
(7595, 'fa', 'فمینیست', 211),
(7596, 'fa', 'باغ', 212),
(7597, 'fa', 'اوت-گارون', 213),
(7598, 'fa', 'گر', 214),
(7599, 'fa', 'جیروند', 215),
(7600, 'fa', 'هیر', 216),
(7601, 'fa', 'هشدار داده می شود', 217),
(7602, 'fa', 'ایندور', 218),
(7603, 'fa', 'Indre-et-Loir', 219),
(7604, 'fa', 'ایزر', 220),
(7605, 'fa', 'یور', 221),
(7606, 'fa', 'لندز', 222),
(7607, 'fa', 'Loir-et-Che', 223),
(7608, 'fa', 'وام گرفتن', 224),
(7609, 'fa', 'Haute-Loir', 225),
(7610, 'fa', 'Loire-Atlantiqu', 226),
(7611, 'fa', 'لیرت', 227),
(7612, 'fa', 'لوط', 228),
(7613, 'fa', 'لوت و گارون', 229),
(7614, 'fa', 'لوزر', 230),
(7615, 'fa', 'ماین et-Loire', 231),
(7616, 'fa', 'مانچ', 232),
(7617, 'fa', 'مارن', 233),
(7618, 'fa', 'هاوت-مارن', 234),
(7619, 'fa', 'مایین', 235),
(7620, 'fa', 'مورته-et-Moselle', 236),
(7621, 'fa', 'مسخره کردن', 237),
(7622, 'fa', 'موربیان', 238),
(7623, 'fa', 'موزل', 239),
(7624, 'fa', 'Nièvr', 240),
(7625, 'fa', 'نورد', 241),
(7626, 'fa', 'اوی', 242),
(7627, 'fa', 'ارن', 243),
(7628, 'fa', 'پاس-کاله', 244),
(7629, 'fa', 'Puy-de-Dôm', 245),
(7630, 'fa', 'Pyrénées-Atlantiques', 246),
(7631, 'fa', 'Hautes-Pyrénée', 247),
(7632, 'fa', 'Pyrénées-Orientales', 248),
(7633, 'fa', 'بس راین', 249),
(7634, 'fa', 'هاوت-رین', 250),
(7635, 'fa', 'رو', 251),
(7636, 'fa', 'Haute-Saône', 252),
(7637, 'fa', 'Saône-et-Loire', 253),
(7638, 'fa', 'سارته', 254),
(7639, 'fa', 'ساووی', 255),
(7640, 'fa', 'هاو-ساووی', 256),
(7641, 'fa', 'پاری', 257),
(7642, 'fa', 'Seine-Maritime', 258),
(7643, 'fa', 'Seine-et-Marn', 259),
(7644, 'fa', 'ایولینز', 260),
(7645, 'fa', 'Deux-Sèvres', 261),
(7646, 'fa', 'سمی', 262),
(7647, 'fa', 'ضعف', 263),
(7648, 'fa', 'Tarn-et-Garonne', 264),
(7649, 'fa', 'وار', 265),
(7650, 'fa', 'ووکلوز', 266),
(7651, 'fa', 'وندیه', 267),
(7652, 'fa', 'وین', 268),
(7653, 'fa', 'هاوت-وین', 269),
(7654, 'fa', 'رأی دادن', 270),
(7655, 'fa', 'یون', 271),
(7656, 'fa', 'سرزمین-دو-بلفورت', 272),
(7657, 'fa', 'اسون', 273),
(7658, 'fa', 'هاوتز دی سی', 274),
(7659, 'fa', 'Seine-Saint-Deni', 275),
(7660, 'fa', 'والد مارن', 276),
(7661, 'fa', 'Val-d\'Ois', 277),
(7662, 'fa', 'آلبا', 278),
(7663, 'fa', 'آرا', 279),
(7664, 'fa', 'Argeș', 280),
(7665, 'fa', 'باکو', 281),
(7666, 'fa', 'بیهور', 282),
(7667, 'fa', 'بیستریا-نسوود', 283),
(7668, 'fa', 'بوتانی', 284),
(7669, 'fa', 'برازوف', 285),
(7670, 'fa', 'Brăila', 286),
(7671, 'fa', 'București', 287),
(7672, 'fa', 'بوز', 288),
(7673, 'fa', 'کارا- Severin', 289),
(7674, 'fa', 'کالیراسی', 290),
(7675, 'fa', 'كلوژ', 291),
(7676, 'fa', 'کنستانس', 292),
(7677, 'fa', 'کواسنا', 293),
(7678, 'fa', 'Dâmbovița', 294),
(7679, 'fa', 'دال', 295),
(7680, 'fa', 'گالشی', 296),
(7681, 'fa', 'جورجیو', 297),
(7682, 'fa', 'گور', 298),
(7683, 'fa', 'هارگیتا', 299),
(7684, 'fa', 'هوندهار', 300),
(7685, 'fa', 'ایالومیشا', 301),
(7686, 'fa', 'Iași', 302),
(7687, 'fa', 'Ilfo', 303),
(7688, 'fa', 'Maramureș', 304),
(7689, 'fa', 'Mehedinți', 305),
(7690, 'fa', 'Mureș', 306),
(7691, 'fa', 'Neamț', 307),
(7692, 'fa', 'اولت', 308),
(7693, 'fa', 'پرهوا', 309),
(7694, 'fa', 'ستو ماره', 310),
(7695, 'fa', 'سلاج', 311),
(7696, 'fa', 'سیبیو', 312),
(7697, 'fa', 'سوساو', 313),
(7698, 'fa', 'تلورمان', 314),
(7699, 'fa', 'تیمیچ', 315),
(7700, 'fa', 'تولسا', 316),
(7701, 'fa', 'واسلوئی', 317),
(7702, 'fa', 'Vâlcea', 318),
(7703, 'fa', 'ورانسا', 319),
(7704, 'fa', 'لاپی', 320),
(7705, 'fa', 'Pohjois-Pohjanmaa', 321),
(7706, 'fa', 'کائینو', 322),
(7707, 'fa', 'Pohjois-Karjala', 323),
(7708, 'fa', 'Pohjois-Savo', 324),
(7709, 'fa', 'اتل-ساوو', 325),
(7710, 'fa', 'کسکی-پوهانما', 326),
(7711, 'fa', 'Pohjanmaa', 327),
(7712, 'fa', 'پیرکانما', 328),
(7713, 'fa', 'ساتاکونتا', 329),
(7714, 'fa', 'کسکی-پوهانما', 330),
(7715, 'fa', 'کسکی-سوومی', 331),
(7716, 'fa', 'Varsinais-Suomi', 332),
(7717, 'fa', 'اتلی کرجالا', 333),
(7718, 'fa', 'Päijät-HAM', 334),
(7719, 'fa', 'کانتا-هوم', 335),
(7720, 'fa', 'یوسیما', 336),
(7721, 'fa', 'اوسیم', 337),
(7722, 'fa', 'کیمنلاکو', 338),
(7723, 'fa', 'آونوانما', 339),
(7724, 'fa', 'هارژوم', 340),
(7725, 'fa', 'سلا', 341),
(7726, 'fa', 'آیدا-ویروما', 342),
(7727, 'fa', 'Jõgevamaa', 343),
(7728, 'fa', 'جوروماا', 344),
(7729, 'fa', 'لونما', 345),
(7730, 'fa', 'لون-ویروما', 346),
(7731, 'fa', 'پالوماا', 347),
(7732, 'fa', 'پورنوما', 348),
(7733, 'fa', 'Raplama', 349),
(7734, 'fa', 'ساارما', 350),
(7735, 'fa', 'تارتوما', 351),
(7736, 'fa', 'والگام', 352),
(7737, 'fa', 'ویلجاندیم', 353),
(7738, 'fa', 'Võrumaa', 354),
(7739, 'fa', 'داگاوپیل', 355),
(7740, 'fa', 'جلگاو', 356),
(7741, 'fa', 'جکابیل', 357),
(7742, 'fa', 'جرمل', 358),
(7743, 'fa', 'لیپجا', 359),
(7744, 'fa', 'شهرستان لیپاج', 360),
(7745, 'fa', 'روژن', 361),
(7746, 'fa', 'راگ', 362),
(7747, 'fa', 'شهرستان ریگ', 363),
(7748, 'fa', 'والمییرا', 364),
(7749, 'fa', 'Ventspils', 365),
(7750, 'fa', 'آگلوناس نوادا', 366),
(7751, 'fa', 'تازه کاران آیزکرایکلس', 367),
(7752, 'fa', 'تازه واردان', 368),
(7753, 'fa', 'شهرستا', 369),
(7754, 'fa', 'نوازندگان آلوجاس', 370),
(7755, 'fa', 'تازه های آلسونگاس', 371),
(7756, 'fa', 'شهرستان آلوکس', 372),
(7757, 'fa', 'تازه کاران آماتاس', 373),
(7758, 'fa', 'میمون های تازه', 374),
(7759, 'fa', 'نوادا را آویز می کند', 375),
(7760, 'fa', 'شهرستان بابی', 376),
(7761, 'fa', 'Baldones novad', 377),
(7762, 'fa', 'نوین های بالتیناوا', 378),
(7763, 'fa', 'Balvu novad', 379),
(7764, 'fa', 'نوازندگان باسکاس', 380),
(7765, 'fa', 'شهرستان بورین', 381),
(7766, 'fa', 'شهرستان بروچن', 382),
(7767, 'fa', 'بوردنیکو نوآوران', 383),
(7768, 'fa', 'تازه کارنیکاوا', 384),
(7769, 'fa', 'نوازان سزوینس', 385),
(7770, 'fa', 'نوادگان Cibla', 386),
(7771, 'fa', 'شهرستان Cesis', 387),
(7772, 'fa', 'تازه های داگدا', 388),
(7773, 'fa', 'داوگاوپیلز نوادا', 389),
(7774, 'fa', 'دابل نوادی', 390),
(7775, 'fa', 'تازه کارهای دنداگاس', 391),
(7776, 'fa', 'نوباد دوربس', 392),
(7777, 'fa', 'مشغول تازه کارها است', 393),
(7778, 'fa', 'گرکالنس نواد', 394),
(7779, 'fa', 'یا شهرستان گروبی', 395),
(7780, 'fa', 'تازه های گلبنس', 396),
(7781, 'fa', 'Iecavas novads', 397),
(7782, 'fa', 'شهرستان ایسکل', 398),
(7783, 'fa', 'ایالت ایلکست', 399),
(7784, 'fa', 'کنددو د اینچوکالن', 400),
(7785, 'fa', 'نوجواد Jaunjelgavas', 401),
(7786, 'fa', 'تازه های Jaunpiebalgas', 402),
(7787, 'fa', 'شهرستان جونپیلس', 403),
(7788, 'fa', 'شهرستان جگلو', 404),
(7789, 'fa', 'شهرستان جکابیل', 405),
(7790, 'fa', 'شهرستان کنداوا', 406),
(7791, 'fa', 'شهرستان کوکنز', 407),
(7792, 'fa', 'شهرستان کریمولد', 408),
(7793, 'fa', 'شهرستان کرستپیل', 409),
(7794, 'fa', 'شهرستان کراسلاو', 410),
(7795, 'fa', 'کاندادو د کلدیگا', 411),
(7796, 'fa', 'کاندادو د کارساوا', 412),
(7797, 'fa', 'شهرستان لیولوارد', 413),
(7798, 'fa', 'شهرستان لیمباشی', 414),
(7799, 'fa', 'ای ولسوالی لوبون', 415),
(7800, 'fa', 'شهرستان لودزا', 416),
(7801, 'fa', 'شهرستان لیگات', 417),
(7802, 'fa', 'شهرستان لیوانی', 418),
(7803, 'fa', 'شهرستان مادونا', 419),
(7804, 'fa', 'شهرستان مازسال', 420),
(7805, 'fa', 'شهرستان مالپیلس', 421),
(7806, 'fa', 'شهرستان Mārupe', 422),
(7807, 'fa', 'ا کنددو د نوکشنی', 423),
(7808, 'fa', 'کاملاً یک شهرستان', 424),
(7809, 'fa', 'شهرستان نیکا', 425),
(7810, 'fa', 'شهرستان اوگر', 426),
(7811, 'fa', 'شهرستان اولین', 427),
(7812, 'fa', 'شهرستان اوزولنیکی', 428),
(7813, 'fa', 'شهرستان پرلیلی', 429),
(7814, 'fa', 'شهرستان Priekule', 430),
(7815, 'fa', 'Condado de Priekuļi', 431),
(7816, 'fa', 'شهرستان در حال حرکت', 432),
(7817, 'fa', 'شهرستان پاویلوستا', 433),
(7818, 'fa', 'شهرستان Plavinas', 4),
(7819, 'fa', 'شهرستان راونا', 435),
(7820, 'fa', 'شهرستان ریبیشی', 436),
(7821, 'fa', 'شهرستان روجا', 437),
(7822, 'fa', 'شهرستان روپازی', 438),
(7823, 'fa', 'شهرستان روساوا', 439),
(7824, 'fa', 'شهرستان روگی', 440),
(7825, 'fa', 'شهرستان راندل', 441),
(7826, 'fa', 'شهرستان ریزکن', 442),
(7827, 'fa', 'شهرستان روژینا', 443),
(7828, 'fa', 'شهرداری Salacgriva', 444),
(7829, 'fa', 'منطقه جزیره', 445),
(7830, 'fa', 'شهرستان Salaspils', 446),
(7831, 'fa', 'شهرستان سالدوس', 447),
(7832, 'fa', 'شهرستان ساولکرستی', 448),
(7833, 'fa', 'شهرستان سیگولدا', 449),
(7834, 'fa', 'شهرستان Skrunda', 450),
(7835, 'fa', 'شهرستان Skrīveri', 451),
(7836, 'fa', 'شهرستان Smiltene', 452),
(7837, 'fa', 'شهرستان ایستینی', 453),
(7838, 'fa', 'شهرستان استرنشی', 454),
(7839, 'fa', 'منطقه کاشت', 455),
(7840, 'fa', 'شهرستان تالسی', 456),
(7841, 'fa', 'توکومس', 457),
(7842, 'fa', 'شهرستان تورت', 458),
(7843, 'fa', 'یا شهرستان وایودود', 459),
(7844, 'fa', 'شهرستان والکا', 460),
(7845, 'fa', 'شهرستان Valmiera', 461),
(7846, 'fa', 'شهرستان وارکانی', 462),
(7847, 'fa', 'شهرستان Vecpiebalga', 463),
(7848, 'fa', 'شهرستان وکومنیکی', 464),
(7849, 'fa', 'شهرستان ونتسپیل', 465),
(7850, 'fa', 'کنددو د بازدید', 466),
(7851, 'fa', 'شهرستان ویلاکا', 467),
(7852, 'fa', 'شهرستان ویلانی', 468),
(7853, 'fa', 'شهرستان واركاوا', 469),
(7854, 'fa', 'شهرستان زیلوپ', 470),
(7855, 'fa', 'شهرستان آدازی', 471),
(7856, 'fa', 'شهرستان ارگلو', 472),
(7857, 'fa', 'شهرستان کگومس', 473),
(7858, 'fa', 'شهرستان ککاوا', 474),
(7859, 'fa', 'شهرستان Alytus', 475),
(7860, 'fa', 'شهرستان Kaunas', 476),
(7861, 'fa', 'شهرستان کلایپدا', 477),
(7862, 'fa', 'شهرستان ماریجامپولی', 478),
(7863, 'fa', 'شهرستان پانویسیز', 479),
(7864, 'fa', 'شهرستان سیاولیا', 480),
(7865, 'fa', 'شهرستان تاجیج', 481),
(7866, 'fa', 'شهرستان تلشیا', 482),
(7867, 'fa', 'شهرستان اوتنا', 483),
(7868, 'fa', 'شهرستان ویلنیوس', 484),
(7869, 'fa', 'جریب', 485),
(7870, 'fa', 'حالت', 486),
(7871, 'fa', 'آمپá', 487),
(7872, 'fa', 'آمازون', 488),
(7873, 'fa', 'باهی', 489),
(7874, 'fa', 'سارا', 490),
(7875, 'fa', 'روح القدس', 491),
(7876, 'fa', 'برو', 492),
(7877, 'fa', 'مارانهائ', 493),
(7878, 'fa', 'ماتو گروسو', 494),
(7879, 'fa', 'Mato Grosso do Sul', 495),
(7880, 'fa', 'ایالت میناس گرایس', 496),
(7881, 'fa', 'پار', 497),
(7882, 'fa', 'حالت', 498),
(7883, 'fa', 'پارانا', 499),
(7884, 'fa', 'حال', 500),
(7885, 'fa', 'پیازو', 501),
(7886, 'fa', 'ریو دوژانیرو', 502),
(7887, 'fa', 'ریو گراند دو نورته', 503),
(7888, 'fa', 'ریو گراند دو سول', 504),
(7889, 'fa', 'Rondôni', 505),
(7890, 'fa', 'Roraim', 506),
(7891, 'fa', 'سانتا کاتارینا', 507),
(7892, 'fa', 'پ', 508),
(7893, 'fa', 'Sergip', 509),
(7894, 'fa', 'توکانتین', 510),
(7895, 'fa', 'منطقه فدرال', 511),
(7896, 'fa', 'شهرستان زاگرب', 512),
(7897, 'fa', 'Condado de Krapina-Zagorj', 513),
(7898, 'fa', 'شهرستان سیساک-موسلاوینا', 514),
(7899, 'fa', 'شهرستان کارلوواک', 515),
(7900, 'fa', 'شهرداری واراžدین', 516),
(7901, 'fa', 'Condo de Koprivnica-Križevci', 517),
(7902, 'fa', 'محل سکونت د بیلوار-بلوگورا', 518),
(7903, 'fa', 'Condado de Primorje-Gorski kotar', 519),
(7904, 'fa', 'شهرستان لیکا-سنج', 520),
(7905, 'fa', 'Condado de Virovitica-Podravina', 521),
(7906, 'fa', 'شهرستان پوژگا-اسلاونیا', 522),
(7907, 'fa', 'Condado de Brod-Posavina', 523),
(7908, 'fa', 'شهرستان زجر', 524),
(7909, 'fa', 'Condado de Osijek-Baranja', 525),
(7910, 'fa', 'Condo de Sibenik-Knin', 526),
(7911, 'fa', 'Condado de Vukovar-Srijem', 527),
(7912, 'fa', 'شهرستان اسپلیت-Dalmatia', 528),
(7913, 'fa', 'شهرستان ایستیا', 529),
(7914, 'fa', 'Condado de Dubrovnik-Neretva', 530),
(7915, 'fa', 'شهرستان Međimurje', 531),
(7916, 'fa', 'شهر زاگرب', 532),
(7917, 'fa', 'جزایر آندامان و نیکوبار', 533),
(7918, 'fa', 'آندرا پرادش', 534),
(7919, 'fa', 'آروناچال پرادش', 535),
(7920, 'fa', 'آسام', 536),
(7921, 'fa', 'Biha', 537),
(7922, 'fa', 'چاندیگار', 538),
(7923, 'fa', 'چاتیسگار', 539),
(7924, 'fa', 'دادرا و نگار هاولی', 540),
(7925, 'fa', 'دامان و دیو', 541),
(7926, 'fa', 'دهلی', 542),
(7927, 'fa', 'گوا', 543),
(7928, 'fa', 'گجرات', 544),
(7929, 'fa', 'هاریانا', 545),
(7930, 'fa', 'هیماچال پرادش', 546),
(7931, 'fa', 'جامو و کشمیر', 547),
(7932, 'fa', 'جهخند', 548),
(7933, 'fa', 'کارناتاکا', 549),
(7934, 'fa', 'کرال', 550),
(7935, 'fa', 'لاکشادوپ', 551),
(7936, 'fa', 'مادیا پرادش', 552),
(7937, 'fa', 'ماهاراشترا', 553),
(7938, 'fa', 'مانی پور', 554),
(7939, 'fa', 'مگالایا', 555),
(7940, 'fa', 'مزورام', 556),
(7941, 'fa', 'ناگلند', 557),
(7942, 'fa', 'ادیشا', 558),
(7943, 'fa', 'میناکاری', 559),
(7944, 'fa', 'پنجا', 560),
(7945, 'fa', 'راجستان', 561),
(7946, 'fa', 'سیکیم', 562),
(7947, 'fa', 'تامیل نادو', 563),
(7948, 'fa', 'تلنگانا', 564),
(7949, 'fa', 'تریپورا', 565),
(7950, 'fa', 'اوتار پرادش', 566),
(7951, 'fa', 'اوتاراکند', 567),
(7952, 'fa', 'بنگال غرب', 568),
(7953, 'pt_BR', 'Alabama', 1),
(7954, 'pt_BR', 'Alaska', 2),
(7955, 'pt_BR', 'Samoa Americana', 3),
(7956, 'pt_BR', 'Arizona', 4),
(7957, 'pt_BR', 'Arkansas', 5),
(7958, 'pt_BR', 'Forças Armadas da África', 6),
(7959, 'pt_BR', 'Forças Armadas das Américas', 7),
(7960, 'pt_BR', 'Forças Armadas do Canadá', 8),
(7961, 'pt_BR', 'Forças Armadas da Europa', 9),
(7962, 'pt_BR', 'Forças Armadas do Oriente Médio', 10),
(7963, 'pt_BR', 'Forças Armadas do Pacífico', 11),
(7964, 'pt_BR', 'California', 12),
(7965, 'pt_BR', 'Colorado', 13),
(7966, 'pt_BR', 'Connecticut', 14),
(7967, 'pt_BR', 'Delaware', 15),
(7968, 'pt_BR', 'Distrito de Columbia', 16),
(7969, 'pt_BR', 'Estados Federados da Micronésia', 17),
(7970, 'pt_BR', 'Florida', 18),
(7971, 'pt_BR', 'Geórgia', 19),
(7972, 'pt_BR', 'Guam', 20),
(7973, 'pt_BR', 'Havaí', 21),
(7974, 'pt_BR', 'Idaho', 22),
(7975, 'pt_BR', 'Illinois', 23),
(7976, 'pt_BR', 'Indiana', 24),
(7977, 'pt_BR', 'Iowa', 25),
(7978, 'pt_BR', 'Kansas', 26),
(7979, 'pt_BR', 'Kentucky', 27),
(7980, 'pt_BR', 'Louisiana', 28),
(7981, 'pt_BR', 'Maine', 29),
(7982, 'pt_BR', 'Ilhas Marshall', 30),
(7983, 'pt_BR', 'Maryland', 31),
(7984, 'pt_BR', 'Massachusetts', 32),
(7985, 'pt_BR', 'Michigan', 33),
(7986, 'pt_BR', 'Minnesota', 34),
(7987, 'pt_BR', 'Mississippi', 35),
(7988, 'pt_BR', 'Missouri', 36),
(7989, 'pt_BR', 'Montana', 37),
(7990, 'pt_BR', 'Nebraska', 38),
(7991, 'pt_BR', 'Nevada', 39),
(7992, 'pt_BR', 'New Hampshire', 40),
(7993, 'pt_BR', 'Nova Jersey', 41),
(7994, 'pt_BR', 'Novo México', 42),
(7995, 'pt_BR', 'Nova York', 43),
(7996, 'pt_BR', 'Carolina do Norte', 44),
(7997, 'pt_BR', 'Dakota do Norte', 45),
(7998, 'pt_BR', 'Ilhas Marianas do Norte', 46),
(7999, 'pt_BR', 'Ohio', 47),
(8000, 'pt_BR', 'Oklahoma', 48),
(8001, 'pt_BR', 'Oregon', 4),
(8002, 'pt_BR', 'Palau', 50),
(8003, 'pt_BR', 'Pensilvânia', 51),
(8004, 'pt_BR', 'Porto Rico', 52),
(8005, 'pt_BR', 'Rhode Island', 53),
(8006, 'pt_BR', 'Carolina do Sul', 54),
(8007, 'pt_BR', 'Dakota do Sul', 55),
(8008, 'pt_BR', 'Tennessee', 56),
(8009, 'pt_BR', 'Texas', 57),
(8010, 'pt_BR', 'Utah', 58),
(8011, 'pt_BR', 'Vermont', 59),
(8012, 'pt_BR', 'Ilhas Virgens', 60),
(8013, 'pt_BR', 'Virginia', 61),
(8014, 'pt_BR', 'Washington', 62),
(8015, 'pt_BR', 'West Virginia', 63),
(8016, 'pt_BR', 'Wisconsin', 64),
(8017, 'pt_BR', 'Wyoming', 65),
(8018, 'pt_BR', 'Alberta', 66),
(8019, 'pt_BR', 'Colúmbia Britânica', 67),
(8020, 'pt_BR', 'Manitoba', 68),
(8021, 'pt_BR', 'Terra Nova e Labrador', 69),
(8022, 'pt_BR', 'New Brunswick', 70),
(8023, 'pt_BR', 'Nova Escócia', 7),
(8024, 'pt_BR', 'Territórios do Noroeste', 72),
(8025, 'pt_BR', 'Nunavut', 73),
(8026, 'pt_BR', 'Ontario', 74),
(8027, 'pt_BR', 'Ilha do Príncipe Eduardo', 75),
(8028, 'pt_BR', 'Quebec', 76),
(8029, 'pt_BR', 'Saskatchewan', 77),
(8030, 'pt_BR', 'Território yukon', 78),
(8031, 'pt_BR', 'Niedersachsen', 79),
(8032, 'pt_BR', 'Baden-Wurttemberg', 80),
(8033, 'pt_BR', 'Bayern', 81),
(8034, 'pt_BR', 'Berlim', 82),
(8035, 'pt_BR', 'Brandenburg', 83),
(8036, 'pt_BR', 'Bremen', 84),
(8037, 'pt_BR', 'Hamburgo', 85),
(8038, 'pt_BR', 'Hessen', 86),
(8039, 'pt_BR', 'Mecklenburg-Vorpommern', 87),
(8040, 'pt_BR', 'Nordrhein-Westfalen', 88),
(8041, 'pt_BR', 'Renânia-Palatinado', 8),
(8042, 'pt_BR', 'Sarre', 90),
(8043, 'pt_BR', 'Sachsen', 91),
(8044, 'pt_BR', 'Sachsen-Anhalt', 92),
(8045, 'pt_BR', 'Schleswig-Holstein', 93),
(8046, 'pt_BR', 'Turíngia', 94),
(8047, 'pt_BR', 'Viena', 95),
(8048, 'pt_BR', 'Baixa Áustria', 96),
(8049, 'pt_BR', 'Oberösterreich', 97),
(8050, 'pt_BR', 'Salzburg', 98),
(8051, 'pt_BR', 'Caríntia', 99),
(8052, 'pt_BR', 'Steiermark', 100),
(8053, 'pt_BR', 'Tirol', 101),
(8054, 'pt_BR', 'Burgenland', 102),
(8055, 'pt_BR', 'Vorarlberg', 103),
(8056, 'pt_BR', 'Aargau', 104),
(8057, 'pt_BR', 'Appenzell Innerrhoden', 105),
(8058, 'pt_BR', 'Appenzell Ausserrhoden', 106),
(8059, 'pt_BR', 'Bern', 107),
(8060, 'pt_BR', 'Basel-Landschaft', 108),
(8061, 'pt_BR', 'Basel-Stadt', 109),
(8062, 'pt_BR', 'Freiburg', 110),
(8063, 'pt_BR', 'Genf', 111),
(8064, 'pt_BR', 'Glarus', 112),
(8065, 'pt_BR', 'Grisons', 113),
(8066, 'pt_BR', 'Jura', 114),
(8067, 'pt_BR', 'Luzern', 115),
(8068, 'pt_BR', 'Neuenburg', 116),
(8069, 'pt_BR', 'Nidwalden', 117),
(8070, 'pt_BR', 'Obwalden', 118),
(8071, 'pt_BR', 'St. Gallen', 119),
(8072, 'pt_BR', 'Schaffhausen', 120),
(8073, 'pt_BR', 'Solothurn', 121),
(8074, 'pt_BR', 'Schwyz', 122),
(8075, 'pt_BR', 'Thurgau', 123),
(8076, 'pt_BR', 'Tessin', 124),
(8077, 'pt_BR', 'Uri', 125),
(8078, 'pt_BR', 'Waadt', 126),
(8079, 'pt_BR', 'Wallis', 127),
(8080, 'pt_BR', 'Zug', 128),
(8081, 'pt_BR', 'Zurique', 129),
(8082, 'pt_BR', 'Corunha', 130),
(8083, 'pt_BR', 'Álava', 131),
(8084, 'pt_BR', 'Albacete', 132),
(8085, 'pt_BR', 'Alicante', 133),
(8086, 'pt_BR', 'Almeria', 134),
(8087, 'pt_BR', 'Astúrias', 135),
(8088, 'pt_BR', 'Avila', 136),
(8089, 'pt_BR', 'Badajoz', 137),
(8090, 'pt_BR', 'Baleares', 138),
(8091, 'pt_BR', 'Barcelona', 139),
(8092, 'pt_BR', 'Burgos', 140),
(8093, 'pt_BR', 'Caceres', 141),
(8094, 'pt_BR', 'Cadiz', 142),
(8095, 'pt_BR', 'Cantábria', 143),
(8096, 'pt_BR', 'Castellon', 144),
(8097, 'pt_BR', 'Ceuta', 145),
(8098, 'pt_BR', 'Ciudad Real', 146),
(8099, 'pt_BR', 'Cordoba', 147),
(8100, 'pt_BR', 'Cuenca', 148),
(8101, 'pt_BR', 'Girona', 149),
(8102, 'pt_BR', 'Granada', 150),
(8103, 'pt_BR', 'Guadalajara', 151),
(8104, 'pt_BR', 'Guipuzcoa', 152),
(8105, 'pt_BR', 'Huelva', 153),
(8106, 'pt_BR', 'Huesca', 154),
(8107, 'pt_BR', 'Jaen', 155),
(8108, 'pt_BR', 'La Rioja', 156),
(8109, 'pt_BR', 'Las Palmas', 157),
(8110, 'pt_BR', 'Leon', 158),
(8111, 'pt_BR', 'Lleida', 159),
(8112, 'pt_BR', 'Lugo', 160),
(8113, 'pt_BR', 'Madri', 161),
(8114, 'pt_BR', 'Málaga', 162),
(8115, 'pt_BR', 'Melilla', 163),
(8116, 'pt_BR', 'Murcia', 164),
(8117, 'pt_BR', 'Navarra', 165),
(8118, 'pt_BR', 'Ourense', 166),
(8119, 'pt_BR', 'Palencia', 167),
(8120, 'pt_BR', 'Pontevedra', 168),
(8121, 'pt_BR', 'Salamanca', 169),
(8122, 'pt_BR', 'Santa Cruz de Tenerife', 170),
(8123, 'pt_BR', 'Segovia', 171),
(8124, 'pt_BR', 'Sevilla', 172),
(8125, 'pt_BR', 'Soria', 173),
(8126, 'pt_BR', 'Tarragona', 174),
(8127, 'pt_BR', 'Teruel', 175),
(8128, 'pt_BR', 'Toledo', 176),
(8129, 'pt_BR', 'Valencia', 177),
(8130, 'pt_BR', 'Valladolid', 178),
(8131, 'pt_BR', 'Vizcaya', 179),
(8132, 'pt_BR', 'Zamora', 180),
(8133, 'pt_BR', 'Zaragoza', 181),
(8134, 'pt_BR', 'Ain', 182),
(8135, 'pt_BR', 'Aisne', 183),
(8136, 'pt_BR', 'Allier', 184),
(8137, 'pt_BR', 'Alpes da Alta Provença', 185),
(8138, 'pt_BR', 'Altos Alpes', 186),
(8139, 'pt_BR', 'Alpes-Maritimes', 187),
(8140, 'pt_BR', 'Ardèche', 188),
(8141, 'pt_BR', 'Ardennes', 189),
(8142, 'pt_BR', 'Ariege', 190),
(8143, 'pt_BR', 'Aube', 191),
(8144, 'pt_BR', 'Aude', 192),
(8145, 'pt_BR', 'Aveyron', 193),
(8146, 'pt_BR', 'BOCAS DO Rhône', 194),
(8147, 'pt_BR', 'Calvados', 195),
(8148, 'pt_BR', 'Cantal', 196),
(8149, 'pt_BR', 'Charente', 197),
(8150, 'pt_BR', 'Charente-Maritime', 198),
(8151, 'pt_BR', 'Cher', 199),
(8152, 'pt_BR', 'Corrèze', 200),
(8153, 'pt_BR', 'Corse-du-Sud', 201),
(8154, 'pt_BR', 'Alta Córsega', 202),
(8155, 'pt_BR', 'Costa d\'OrCorrèze', 203),
(8156, 'pt_BR', 'Cotes d\'Armor', 204),
(8157, 'pt_BR', 'Creuse', 205),
(8158, 'pt_BR', 'Dordogne', 206),
(8159, 'pt_BR', 'Doubs', 207),
(8160, 'pt_BR', 'DrômeFinistère', 208),
(8161, 'pt_BR', 'Eure', 209),
(8162, 'pt_BR', 'Eure-et-Loir', 210),
(8163, 'pt_BR', 'Finistère', 211),
(8164, 'pt_BR', 'Gard', 212),
(8165, 'pt_BR', 'Haute-Garonne', 213),
(8166, 'pt_BR', 'Gers', 214),
(8167, 'pt_BR', 'Gironde', 215),
(8168, 'pt_BR', 'Hérault', 216),
(8169, 'pt_BR', 'Ille-et-Vilaine', 217),
(8170, 'pt_BR', 'Indre', 218),
(8171, 'pt_BR', 'Indre-et-Loire', 219),
(8172, 'pt_BR', 'Isère', 220),
(8173, 'pt_BR', 'Jura', 221),
(8174, 'pt_BR', 'Landes', 222),
(8175, 'pt_BR', 'Loir-et-Cher', 223),
(8176, 'pt_BR', 'Loire', 224),
(8177, 'pt_BR', 'Haute-Loire', 22),
(8178, 'pt_BR', 'Loire-Atlantique', 226),
(8179, 'pt_BR', 'Loiret', 227),
(8180, 'pt_BR', 'Lot', 228),
(8181, 'pt_BR', 'Lot e Garona', 229),
(8182, 'pt_BR', 'Lozère', 230),
(8183, 'pt_BR', 'Maine-et-Loire', 231),
(8184, 'pt_BR', 'Manche', 232),
(8185, 'pt_BR', 'Marne', 233),
(8186, 'pt_BR', 'Haute-Marne', 234),
(8187, 'pt_BR', 'Mayenne', 235),
(8188, 'pt_BR', 'Meurthe-et-Moselle', 236),
(8189, 'pt_BR', 'Meuse', 237),
(8190, 'pt_BR', 'Morbihan', 238),
(8191, 'pt_BR', 'Moselle', 239),
(8192, 'pt_BR', 'Nièvre', 240),
(8193, 'pt_BR', 'Nord', 241),
(8194, 'pt_BR', 'Oise', 242),
(8195, 'pt_BR', 'Orne', 243),
(8196, 'pt_BR', 'Pas-de-Calais', 244),
(8197, 'pt_BR', 'Puy-de-Dôme', 24),
(8198, 'pt_BR', 'Pirineus Atlânticos', 246),
(8199, 'pt_BR', 'Hautes-Pyrénées', 247),
(8200, 'pt_BR', 'Pirineus Orientais', 248),
(8201, 'pt_BR', 'Bas-Rhin', 249),
(8202, 'pt_BR', 'Alto Reno', 250),
(8203, 'pt_BR', 'Rhône', 251),
(8204, 'pt_BR', 'Haute-Saône', 252),
(8205, 'pt_BR', 'Saône-et-Loire', 253),
(8206, 'pt_BR', 'Sarthe', 25),
(8207, 'pt_BR', 'Savoie', 255),
(8208, 'pt_BR', 'Alta Sabóia', 256),
(8209, 'pt_BR', 'Paris', 257),
(8210, 'pt_BR', 'Seine-Maritime', 258),
(8211, 'pt_BR', 'Seine-et-Marne', 259),
(8212, 'pt_BR', 'Yvelines', 260),
(8213, 'pt_BR', 'Deux-Sèvres', 261),
(8214, 'pt_BR', 'Somme', 262),
(8215, 'pt_BR', 'Tarn', 263),
(8216, 'pt_BR', 'Tarn-et-Garonne', 264),
(8217, 'pt_BR', 'Var', 265),
(8218, 'pt_BR', 'Vaucluse', 266),
(8219, 'pt_BR', 'Compradora', 267),
(8220, 'pt_BR', 'Vienne', 268),
(8221, 'pt_BR', 'Haute-Vienne', 269),
(8222, 'pt_BR', 'Vosges', 270),
(8223, 'pt_BR', 'Yonne', 271),
(8224, 'pt_BR', 'Território de Belfort', 272),
(8225, 'pt_BR', 'Essonne', 273),
(8226, 'pt_BR', 'Altos do Sena', 274),
(8227, 'pt_BR', 'Seine-Saint-Denis', 275),
(8228, 'pt_BR', 'Val-de-Marne', 276),
(8229, 'pt_BR', 'Val-d\'Oise', 277),
(8230, 'pt_BR', 'Alba', 278),
(8231, 'pt_BR', 'Arad', 279),
(8232, 'pt_BR', 'Arges', 280),
(8233, 'pt_BR', 'Bacau', 281),
(8234, 'pt_BR', 'Bihor', 282),
(8235, 'pt_BR', 'Bistrita-Nasaud', 283),
(8236, 'pt_BR', 'Botosani', 284),
(8237, 'pt_BR', 'Brașov', 285),
(8238, 'pt_BR', 'Braila', 286),
(8239, 'pt_BR', 'Bucareste', 287),
(8240, 'pt_BR', 'Buzau', 288),
(8241, 'pt_BR', 'Caras-Severin', 289),
(8242, 'pt_BR', 'Călărași', 290),
(8243, 'pt_BR', 'Cluj', 291),
(8244, 'pt_BR', 'Constanta', 292),
(8245, 'pt_BR', 'Covasna', 29),
(8246, 'pt_BR', 'Dambovita', 294),
(8247, 'pt_BR', 'Dolj', 295),
(8248, 'pt_BR', 'Galati', 296),
(8249, 'pt_BR', 'Giurgiu', 297),
(8250, 'pt_BR', 'Gorj', 298),
(8251, 'pt_BR', 'Harghita', 299),
(8252, 'pt_BR', 'Hunedoara', 300),
(8253, 'pt_BR', 'Ialomita', 301),
(8254, 'pt_BR', 'Iasi', 302),
(8255, 'pt_BR', 'Ilfov', 303),
(8256, 'pt_BR', 'Maramures', 304),
(8257, 'pt_BR', 'Maramures', 305),
(8258, 'pt_BR', 'Mures', 306),
(8259, 'pt_BR', 'alemão', 307),
(8260, 'pt_BR', 'Olt', 308),
(8261, 'pt_BR', 'Prahova', 309),
(8262, 'pt_BR', 'Satu-Mare', 310),
(8263, 'pt_BR', 'Salaj', 311),
(8264, 'pt_BR', 'Sibiu', 312),
(8265, 'pt_BR', 'Suceava', 313),
(8266, 'pt_BR', 'Teleorman', 314),
(8267, 'pt_BR', 'Timis', 315),
(8268, 'pt_BR', 'Tulcea', 316),
(8269, 'pt_BR', 'Vaslui', 317),
(8270, 'pt_BR', 'dale', 318),
(8271, 'pt_BR', 'Vrancea', 319),
(8272, 'pt_BR', 'Lappi', 320),
(8273, 'pt_BR', 'Pohjois-Pohjanmaa', 321),
(8274, 'pt_BR', 'Kainuu', 322),
(8275, 'pt_BR', 'Pohjois-Karjala', 323),
(8276, 'pt_BR', 'Pohjois-Savo', 324),
(8277, 'pt_BR', 'Sul Savo', 325),
(8278, 'pt_BR', 'Ostrobothnia do sul', 326),
(8279, 'pt_BR', 'Pohjanmaa', 327),
(8280, 'pt_BR', 'Pirkanmaa', 328),
(8281, 'pt_BR', 'Satakunta', 329),
(8282, 'pt_BR', 'Keski-Pohjanmaa', 330),
(8283, 'pt_BR', 'Keski-Suomi', 331),
(8284, 'pt_BR', 'Varsinais-Suomi', 332),
(8285, 'pt_BR', 'Carélia do Sul', 333),
(8286, 'pt_BR', 'Päijät-Häme', 334),
(8287, 'pt_BR', 'Kanta-Häme', 335),
(8288, 'pt_BR', 'Uusimaa', 336),
(8289, 'pt_BR', 'Uusimaa', 337),
(8290, 'pt_BR', 'Kymenlaakso', 338),
(8291, 'pt_BR', 'Ahvenanmaa', 339),
(8292, 'pt_BR', 'Harjumaa', 340),
(8293, 'pt_BR', 'Hiiumaa', 341),
(8294, 'pt_BR', 'Ida-Virumaa', 342),
(8295, 'pt_BR', 'Condado de Jõgeva', 343),
(8296, 'pt_BR', 'Condado de Järva', 344),
(8297, 'pt_BR', 'Läänemaa', 345),
(8298, 'pt_BR', 'Condado de Lääne-Viru', 346),
(8299, 'pt_BR', 'Condado de Põlva', 347),
(8300, 'pt_BR', 'Condado de Pärnu', 348),
(8301, 'pt_BR', 'Raplamaa', 349),
(8302, 'pt_BR', 'Saaremaa', 350),
(8303, 'pt_BR', 'Tartumaa', 351),
(8304, 'pt_BR', 'Valgamaa', 352),
(8305, 'pt_BR', 'Viljandimaa', 353),
(8306, 'pt_BR', 'Võrumaa', 354),
(8307, 'pt_BR', 'Daugavpils', 355),
(8308, 'pt_BR', 'Jelgava', 356),
(8309, 'pt_BR', 'Jekabpils', 357),
(8310, 'pt_BR', 'Jurmala', 358),
(8311, 'pt_BR', 'Liepaja', 359),
(8312, 'pt_BR', 'Liepaja County', 360),
(8313, 'pt_BR', 'Rezekne', 361),
(8314, 'pt_BR', 'Riga', 362),
(8315, 'pt_BR', 'Condado de Riga', 363),
(8316, 'pt_BR', 'Valmiera', 364),
(8317, 'pt_BR', 'Ventspils', 365),
(8318, 'pt_BR', 'Aglonas novads', 366),
(8319, 'pt_BR', 'Aizkraukles novads', 367),
(8320, 'pt_BR', 'Aizputes novads', 368),
(8321, 'pt_BR', 'Condado de Akniste', 369),
(8322, 'pt_BR', 'Alojas novads', 370),
(8323, 'pt_BR', 'Alsungas novads', 371),
(8324, 'pt_BR', 'Aluksne County', 372),
(8325, 'pt_BR', 'Amatas novads', 373),
(8326, 'pt_BR', 'Macacos novads', 374),
(8327, 'pt_BR', 'Auces novads', 375),
(8328, 'pt_BR', 'Babītes novads', 376),
(8329, 'pt_BR', 'Baldones novads', 377),
(8330, 'pt_BR', 'Baltinavas novads', 378),
(8331, 'pt_BR', 'Balvu novads', 379),
(8332, 'pt_BR', 'Bauskas novads', 380),
(8333, 'pt_BR', 'Condado de Beverina', 381),
(8334, 'pt_BR', 'Condado de Broceni', 382),
(8335, 'pt_BR', 'Burtnieku novads', 383),
(8336, 'pt_BR', 'Carnikavas novads', 384),
(8337, 'pt_BR', 'Cesvaines novads', 385),
(8338, 'pt_BR', 'Ciblas novads', 386),
(8339, 'pt_BR', 'Cesis county', 387),
(8340, 'pt_BR', 'Dagdas novads', 388),
(8341, 'pt_BR', 'Daugavpils novads', 389),
(8342, 'pt_BR', 'Dobeles novads', 390),
(8343, 'pt_BR', 'Dundagas novads', 391),
(8344, 'pt_BR', 'Durbes novads', 392),
(8345, 'pt_BR', 'Engad novads', 393),
(8346, 'pt_BR', 'Garkalnes novads', 394),
(8347, 'pt_BR', 'O condado de Grobiņa', 395),
(8348, 'pt_BR', 'Gulbenes novads', 396),
(8349, 'pt_BR', 'Iecavas novads', 397),
(8350, 'pt_BR', 'Ikskile county', 398),
(8351, 'pt_BR', 'Ilūkste county', 399),
(8352, 'pt_BR', 'Condado de Inčukalns', 400),
(8353, 'pt_BR', 'Jaunjelgavas novads', 401),
(8354, 'pt_BR', 'Jaunpiebalgas novads', 402),
(8355, 'pt_BR', 'Jaunpils novads', 403),
(8356, 'pt_BR', 'Jelgavas novads', 404),
(8357, 'pt_BR', 'Jekabpils county', 405),
(8358, 'pt_BR', 'Kandavas novads', 406),
(8359, 'pt_BR', 'Kokneses novads', 407),
(8360, 'pt_BR', 'Krimuldas novads', 408),
(8361, 'pt_BR', 'Krustpils novads', 409),
(8362, 'pt_BR', 'Condado de Kraslava', 410),
(8363, 'pt_BR', 'Condado de Kuldīga', 411),
(8364, 'pt_BR', 'Condado de Kārsava', 412),
(8365, 'pt_BR', 'Condado de Lielvarde', 413),
(8366, 'pt_BR', 'Condado de Limbaži', 414),
(8367, 'pt_BR', 'O distrito de Lubāna', 415),
(8368, 'pt_BR', 'Ludzas novads', 416),
(8369, 'pt_BR', 'Ligatne county', 417),
(8370, 'pt_BR', 'Livani county', 418),
(8371, 'pt_BR', 'Madonas novads', 419),
(8372, 'pt_BR', 'Mazsalacas novads', 420),
(8373, 'pt_BR', 'Mālpils county', 421),
(8374, 'pt_BR', 'Mārupe county', 422),
(8375, 'pt_BR', 'O condado de Naukšēni', 423),
(8376, 'pt_BR', 'Neretas novads', 424),
(8377, 'pt_BR', 'Nīca county', 425),
(8378, 'pt_BR', 'Ogres novads', 426),
(8379, 'pt_BR', 'Olaines novads', 427),
(8380, 'pt_BR', 'Ozolnieku novads', 428),
(8381, 'pt_BR', 'Preiļi county', 429),
(8382, 'pt_BR', 'Priekules novads', 430),
(8383, 'pt_BR', 'Condado de Priekuļi', 431),
(8384, 'pt_BR', 'Moving county', 432),
(8385, 'pt_BR', 'Condado de Pavilosta', 433),
(8386, 'pt_BR', 'Condado de Plavinas', 434);
INSERT INTO `country_state_translations` (`id`, `locale`, `default_name`, `country_state_id`) VALUES
(8387, 'pt_BR', 'Raunas novads', 435),
(8388, 'pt_BR', 'Condado de Riebiņi', 436),
(8389, 'pt_BR', 'Rojas novads', 437),
(8390, 'pt_BR', 'Ropazi county', 438),
(8391, 'pt_BR', 'Rucavas novads', 439),
(8392, 'pt_BR', 'Rugāji county', 440),
(8393, 'pt_BR', 'Rundāle county', 441),
(8394, 'pt_BR', 'Rezekne county', 442),
(8395, 'pt_BR', 'Rūjiena county', 443),
(8396, 'pt_BR', 'O município de Salacgriva', 444),
(8397, 'pt_BR', 'Salas novads', 445),
(8398, 'pt_BR', 'Salaspils novads', 446),
(8399, 'pt_BR', 'Saldus novads', 447),
(8400, 'pt_BR', 'Saulkrastu novads', 448),
(8401, 'pt_BR', 'Siguldas novads', 449),
(8402, 'pt_BR', 'Skrundas novads', 450),
(8403, 'pt_BR', 'Skrīveri county', 451),
(8404, 'pt_BR', 'Smiltenes novads', 452),
(8405, 'pt_BR', 'Condado de Stopini', 453),
(8406, 'pt_BR', 'Condado de Strenči', 454),
(8407, 'pt_BR', 'Região de semeadura', 455),
(8408, 'pt_BR', 'Talsu novads', 456),
(8409, 'pt_BR', 'Tukuma novads', 457),
(8410, 'pt_BR', 'Condado de Tērvete', 458),
(8411, 'pt_BR', 'O condado de Vaiņode', 459),
(8412, 'pt_BR', 'Valkas novads', 460),
(8413, 'pt_BR', 'Valmieras novads', 461),
(8414, 'pt_BR', 'Varaklani county', 462),
(8415, 'pt_BR', 'Vecpiebalgas novads', 463),
(8416, 'pt_BR', 'Vecumnieku novads', 464),
(8417, 'pt_BR', 'Ventspils novads', 465),
(8418, 'pt_BR', 'Condado de Viesite', 466),
(8419, 'pt_BR', 'Condado de Vilaka', 467),
(8420, 'pt_BR', 'Vilani county', 468),
(8421, 'pt_BR', 'Condado de Varkava', 469),
(8422, 'pt_BR', 'Zilupes novads', 470),
(8423, 'pt_BR', 'Adazi county', 471),
(8424, 'pt_BR', 'Erglu county', 472),
(8425, 'pt_BR', 'Kegums county', 473),
(8426, 'pt_BR', 'Kekava county', 474),
(8427, 'pt_BR', 'Alytaus Apskritis', 475),
(8428, 'pt_BR', 'Kauno Apskritis', 476),
(8429, 'pt_BR', 'Condado de Klaipeda', 477),
(8430, 'pt_BR', 'Marijampolė county', 478),
(8431, 'pt_BR', 'Panevezys county', 479),
(8432, 'pt_BR', 'Siauliai county', 480),
(8433, 'pt_BR', 'Taurage county', 481),
(8434, 'pt_BR', 'Telšiai county', 482),
(8435, 'pt_BR', 'Utenos Apskritis', 483),
(8436, 'pt_BR', 'Vilniaus Apskritis', 484),
(8437, 'pt_BR', 'Acre', 485),
(8438, 'pt_BR', 'Alagoas', 486),
(8439, 'pt_BR', 'Amapá', 487),
(8440, 'pt_BR', 'Amazonas', 488),
(8441, 'pt_BR', 'Bahia', 489),
(8442, 'pt_BR', 'Ceará', 490),
(8443, 'pt_BR', 'Espírito Santo', 491),
(8444, 'pt_BR', 'Goiás', 492),
(8445, 'pt_BR', 'Maranhão', 493),
(8446, 'pt_BR', 'Mato Grosso', 494),
(8447, 'pt_BR', 'Mato Grosso do Sul', 495),
(8448, 'pt_BR', 'Minas Gerais', 496),
(8449, 'pt_BR', 'Pará', 497),
(8450, 'pt_BR', 'Paraíba', 498),
(8451, 'pt_BR', 'Paraná', 499),
(8452, 'pt_BR', 'Pernambuco', 500),
(8453, 'pt_BR', 'Piauí', 501),
(8454, 'pt_BR', 'Rio de Janeiro', 502),
(8455, 'pt_BR', 'Rio Grande do Norte', 503),
(8456, 'pt_BR', 'Rio Grande do Sul', 504),
(8457, 'pt_BR', 'Rondônia', 505),
(8458, 'pt_BR', 'Roraima', 506),
(8459, 'pt_BR', 'Santa Catarina', 507),
(8460, 'pt_BR', 'São Paulo', 508),
(8461, 'pt_BR', 'Sergipe', 509),
(8462, 'pt_BR', 'Tocantins', 510),
(8463, 'pt_BR', 'Distrito Federal', 511),
(8464, 'pt_BR', 'Condado de Zagreb', 512),
(8465, 'pt_BR', 'Condado de Krapina-Zagorje', 513),
(8466, 'pt_BR', 'Condado de Sisak-Moslavina', 514),
(8467, 'pt_BR', 'Condado de Karlovac', 515),
(8468, 'pt_BR', 'Concelho de Varaždin', 516),
(8469, 'pt_BR', 'Condado de Koprivnica-Križevci', 517),
(8470, 'pt_BR', 'Condado de Bjelovar-Bilogora', 518),
(8471, 'pt_BR', 'Condado de Primorje-Gorski kotar', 519),
(8472, 'pt_BR', 'Condado de Lika-Senj', 520),
(8473, 'pt_BR', 'Condado de Virovitica-Podravina', 521),
(8474, 'pt_BR', 'Condado de Požega-Slavonia', 522),
(8475, 'pt_BR', 'Condado de Brod-Posavina', 523),
(8476, 'pt_BR', 'Condado de Zadar', 524),
(8477, 'pt_BR', 'Condado de Osijek-Baranja', 525),
(8478, 'pt_BR', 'Condado de Šibenik-Knin', 526),
(8479, 'pt_BR', 'Condado de Vukovar-Srijem', 527),
(8480, 'pt_BR', 'Condado de Split-Dalmácia', 528),
(8481, 'pt_BR', 'Condado de Ístria', 529),
(8482, 'pt_BR', 'Condado de Dubrovnik-Neretva', 530),
(8483, 'pt_BR', 'Međimurska županija', 531),
(8484, 'pt_BR', 'Grad Zagreb', 532),
(8485, 'pt_BR', 'Ilhas Andaman e Nicobar', 533),
(8486, 'pt_BR', 'Andhra Pradesh', 534),
(8487, 'pt_BR', 'Arunachal Pradesh', 535),
(8488, 'pt_BR', 'Assam', 536),
(8489, 'pt_BR', 'Bihar', 537),
(8490, 'pt_BR', 'Chandigarh', 538),
(8491, 'pt_BR', 'Chhattisgarh', 539),
(8492, 'pt_BR', 'Dadra e Nagar Haveli', 540),
(8493, 'pt_BR', 'Daman e Diu', 541),
(8494, 'pt_BR', 'Delhi', 542),
(8495, 'pt_BR', 'Goa', 543),
(8496, 'pt_BR', 'Gujarat', 544),
(8497, 'pt_BR', 'Haryana', 545),
(8498, 'pt_BR', 'Himachal Pradesh', 546),
(8499, 'pt_BR', 'Jammu e Caxemira', 547),
(8500, 'pt_BR', 'Jharkhand', 548),
(8501, 'pt_BR', 'Karnataka', 549),
(8502, 'pt_BR', 'Kerala', 550),
(8503, 'pt_BR', 'Lakshadweep', 551),
(8504, 'pt_BR', 'Madhya Pradesh', 552),
(8505, 'pt_BR', 'Maharashtra', 553),
(8506, 'pt_BR', 'Manipur', 554),
(8507, 'pt_BR', 'Meghalaya', 555),
(8508, 'pt_BR', 'Mizoram', 556),
(8509, 'pt_BR', 'Nagaland', 557),
(8510, 'pt_BR', 'Odisha', 558),
(8511, 'pt_BR', 'Puducherry', 559),
(8512, 'pt_BR', 'Punjab', 560),
(8513, 'pt_BR', 'Rajasthan', 561),
(8514, 'pt_BR', 'Sikkim', 562),
(8515, 'pt_BR', 'Tamil Nadu', 563),
(8516, 'pt_BR', 'Telangana', 564),
(8517, 'pt_BR', 'Tripura', 565),
(8518, 'pt_BR', 'Uttar Pradesh', 566),
(8519, 'pt_BR', 'Uttarakhand', 567),
(8520, 'pt_BR', 'Bengala Ocidental', 568);

-- --------------------------------------------------------

--
-- Structure de la table `country_translations`
--

DROP TABLE IF EXISTS `country_translations`;
CREATE TABLE IF NOT EXISTS `country_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `country_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `country_translations_country_id_foreign` (`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3826 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `country_translations`
--

INSERT INTO `country_translations` (`id`, `locale`, `name`, `country_id`) VALUES
(3061, 'ar', 'أفغانستان', 1),
(3062, 'ar', 'جزر آلاند', 2),
(3063, 'ar', 'ألبانيا', 3),
(3064, 'ar', 'الجزائر', 4),
(3065, 'ar', 'ساموا الأمريكية', 5),
(3066, 'ar', 'أندورا', 6),
(3067, 'ar', 'أنغولا', 7),
(3068, 'ar', 'أنغيلا', 8),
(3069, 'ar', 'القارة القطبية الجنوبية', 9),
(3070, 'ar', 'أنتيغوا وبربودا', 10),
(3071, 'ar', 'الأرجنتين', 11),
(3072, 'ar', 'أرمينيا', 12),
(3073, 'ar', 'أروبا', 13),
(3074, 'ar', 'جزيرة الصعود', 14),
(3075, 'ar', 'أستراليا', 15),
(3076, 'ar', 'النمسا', 16),
(3077, 'ar', 'أذربيجان', 17),
(3078, 'ar', 'الباهاما', 18),
(3079, 'ar', 'البحرين', 19),
(3080, 'ar', 'بنغلاديش', 20),
(3081, 'ar', 'بربادوس', 21),
(3082, 'ar', 'روسيا البيضاء', 22),
(3083, 'ar', 'بلجيكا', 23),
(3084, 'ar', 'بليز', 24),
(3085, 'ar', 'بنين', 25),
(3086, 'ar', 'برمودا', 26),
(3087, 'ar', 'بوتان', 27),
(3088, 'ar', 'بوليفيا', 28),
(3089, 'ar', 'البوسنة والهرسك', 29),
(3090, 'ar', 'بوتسوانا', 30),
(3091, 'ar', 'البرازيل', 31),
(3092, 'ar', 'إقليم المحيط البريطاني الهندي', 32),
(3093, 'ar', 'جزر فيرجن البريطانية', 33),
(3094, 'ar', 'بروناي', 34),
(3095, 'ar', 'بلغاريا', 35),
(3096, 'ar', 'بوركينا فاسو', 36),
(3097, 'ar', 'بوروندي', 37),
(3098, 'ar', 'كمبوديا', 38),
(3099, 'ar', 'الكاميرون', 39),
(3100, 'ar', 'كندا', 40),
(3101, 'ar', 'جزر الكناري', 41),
(3102, 'ar', 'الرأس الأخضر', 42),
(3103, 'ar', 'الكاريبي هولندا', 43),
(3104, 'ar', 'جزر كايمان', 44),
(3105, 'ar', 'جمهورية افريقيا الوسطى', 45),
(3106, 'ar', 'سبتة ومليلية', 46),
(3107, 'ar', 'تشاد', 47),
(3108, 'ar', 'تشيلي', 48),
(3109, 'ar', 'الصين', 49),
(3110, 'ar', 'جزيرة الكريسماس', 50),
(3111, 'ar', 'جزر كوكوس (كيلينغ)', 51),
(3112, 'ar', 'كولومبيا', 52),
(3113, 'ar', 'جزر القمر', 53),
(3114, 'ar', 'الكونغو - برازافيل', 54),
(3115, 'ar', 'الكونغو - كينشاسا', 55),
(3116, 'ar', 'جزر كوك', 56),
(3117, 'ar', 'كوستاريكا', 57),
(3118, 'ar', 'ساحل العاج', 58),
(3119, 'ar', 'كرواتيا', 59),
(3120, 'ar', 'كوبا', 60),
(3121, 'ar', 'كوراساو', 61),
(3122, 'ar', 'قبرص', 62),
(3123, 'ar', 'التشيك', 63),
(3124, 'ar', 'الدنمارك', 64),
(3125, 'ar', 'دييغو غارسيا', 65),
(3126, 'ar', 'جيبوتي', 66),
(3127, 'ar', 'دومينيكا', 67),
(3128, 'ar', 'جمهورية الدومنيكان', 68),
(3129, 'ar', 'الإكوادور', 69),
(3130, 'ar', 'مصر', 70),
(3131, 'ar', 'السلفادور', 71),
(3132, 'ar', 'غينيا الإستوائية', 72),
(3133, 'ar', 'إريتريا', 73),
(3134, 'ar', 'استونيا', 74),
(3135, 'ar', 'أثيوبيا', 75),
(3136, 'ar', 'منطقة اليورو', 76),
(3137, 'ar', 'جزر فوكلاند', 77),
(3138, 'ar', 'جزر فاروس', 78),
(3139, 'ar', 'فيجي', 79),
(3140, 'ar', 'فنلندا', 80),
(3141, 'ar', 'فرنسا', 81),
(3142, 'ar', 'غيانا الفرنسية', 82),
(3143, 'ar', 'بولينيزيا الفرنسية', 83),
(3144, 'ar', 'المناطق الجنوبية لفرنسا', 84),
(3145, 'ar', 'الغابون', 85),
(3146, 'ar', 'غامبيا', 86),
(3147, 'ar', 'جورجيا', 87),
(3148, 'ar', 'ألمانيا', 88),
(3149, 'ar', 'غانا', 89),
(3150, 'ar', 'جبل طارق', 90),
(3151, 'ar', 'اليونان', 91),
(3152, 'ar', 'الأرض الخضراء', 92),
(3153, 'ar', 'غرينادا', 93),
(3154, 'ar', 'جوادلوب', 94),
(3155, 'ar', 'غوام', 95),
(3156, 'ar', 'غواتيمالا', 96),
(3157, 'ar', 'غيرنسي', 97),
(3158, 'ar', 'غينيا', 98),
(3159, 'ar', 'غينيا بيساو', 99),
(3160, 'ar', 'غيانا', 100),
(3161, 'ar', 'هايتي', 101),
(3162, 'ar', 'هندوراس', 102),
(3163, 'ar', 'هونج كونج SAR الصين', 103),
(3164, 'ar', 'هنغاريا', 104),
(3165, 'ar', 'أيسلندا', 105),
(3166, 'ar', 'الهند', 106),
(3167, 'ar', 'إندونيسيا', 107),
(3168, 'ar', 'إيران', 108),
(3169, 'ar', 'العراق', 109),
(3170, 'ar', 'أيرلندا', 110),
(3171, 'ar', 'جزيرة آيل أوف مان', 111),
(3172, 'ar', 'إسرائيل', 112),
(3173, 'ar', 'إيطاليا', 113),
(3174, 'ar', 'جامايكا', 114),
(3175, 'ar', 'اليابان', 115),
(3176, 'ar', 'جيرسي', 116),
(3177, 'ar', 'الأردن', 117),
(3178, 'ar', 'كازاخستان', 118),
(3179, 'ar', 'كينيا', 119),
(3180, 'ar', 'كيريباس', 120),
(3181, 'ar', 'كوسوفو', 121),
(3182, 'ar', 'الكويت', 122),
(3183, 'ar', 'قرغيزستان', 123),
(3184, 'ar', 'لاوس', 124),
(3185, 'ar', 'لاتفيا', 125),
(3186, 'ar', 'لبنان', 126),
(3187, 'ar', 'ليسوتو', 127),
(3188, 'ar', 'ليبيريا', 128),
(3189, 'ar', 'ليبيا', 129),
(3190, 'ar', 'ليختنشتاين', 130),
(3191, 'ar', 'ليتوانيا', 131),
(3192, 'ar', 'لوكسمبورغ', 132),
(3193, 'ar', 'ماكاو SAR الصين', 133),
(3194, 'ar', 'مقدونيا', 134),
(3195, 'ar', 'مدغشقر', 135),
(3196, 'ar', 'مالاوي', 136),
(3197, 'ar', 'ماليزيا', 137),
(3198, 'ar', 'جزر المالديف', 138),
(3199, 'ar', 'مالي', 139),
(3200, 'ar', 'مالطا', 140),
(3201, 'ar', 'جزر مارشال', 141),
(3202, 'ar', 'مارتينيك', 142),
(3203, 'ar', 'موريتانيا', 143),
(3204, 'ar', 'موريشيوس', 144),
(3205, 'ar', 'ضائع', 145),
(3206, 'ar', 'المكسيك', 146),
(3207, 'ar', 'ميكرونيزيا', 147),
(3208, 'ar', 'مولدوفا', 148),
(3209, 'ar', 'موناكو', 149),
(3210, 'ar', 'منغوليا', 150),
(3211, 'ar', 'الجبل الأسود', 151),
(3212, 'ar', 'مونتسيرات', 152),
(3213, 'ar', 'المغرب', 153),
(3214, 'ar', 'موزمبيق', 154),
(3215, 'ar', 'ميانمار (بورما)', 155),
(3216, 'ar', 'ناميبيا', 156),
(3217, 'ar', 'ناورو', 157),
(3218, 'ar', 'نيبال', 158),
(3219, 'ar', 'نيبال', 159),
(3220, 'ar', 'كاليدونيا الجديدة', 160),
(3221, 'ar', 'نيوزيلاندا', 161),
(3222, 'ar', 'نيكاراغوا', 162),
(3223, 'ar', 'النيجر', 163),
(3224, 'ar', 'نيجيريا', 164),
(3225, 'ar', 'نيوي', 165),
(3226, 'ar', 'جزيرة نورفولك', 166),
(3227, 'ar', 'كوريا الشماليه', 167),
(3228, 'ar', 'جزر مريانا الشمالية', 168),
(3229, 'ar', 'النرويج', 169),
(3230, 'ar', 'سلطنة عمان', 170),
(3231, 'ar', 'باكستان', 171),
(3232, 'ar', 'بالاو', 172),
(3233, 'ar', 'الاراضي الفلسطينية', 173),
(3234, 'ar', 'بناما', 174),
(3235, 'ar', 'بابوا غينيا الجديدة', 175),
(3236, 'ar', 'باراغواي', 176),
(3237, 'ar', 'بيرو', 177),
(3238, 'ar', 'الفلبين', 178),
(3239, 'ar', 'جزر بيتكيرن', 179),
(3240, 'ar', 'بولندا', 180),
(3241, 'ar', 'البرتغال', 181),
(3242, 'ar', 'بورتوريكو', 182),
(3243, 'ar', 'دولة قطر', 183),
(3244, 'ar', 'جمع شمل', 184),
(3245, 'ar', 'رومانيا', 185),
(3246, 'ar', 'روسيا', 186),
(3247, 'ar', 'رواندا', 187),
(3248, 'ar', 'ساموا', 188),
(3249, 'ar', 'سان مارينو', 189),
(3250, 'ar', 'سانت كيتس ونيفيس', 190),
(3251, 'ar', 'المملكة العربية السعودية', 191),
(3252, 'ar', 'السنغال', 192),
(3253, 'ar', 'صربيا', 193),
(3254, 'ar', 'سيشيل', 194),
(3255, 'ar', 'سيراليون', 195),
(3256, 'ar', 'سنغافورة', 196),
(3257, 'ar', 'سينت مارتن', 197),
(3258, 'ar', 'سلوفاكيا', 198),
(3259, 'ar', 'سلوفينيا', 199),
(3260, 'ar', 'جزر سليمان', 200),
(3261, 'ar', 'الصومال', 201),
(3262, 'ar', 'جنوب أفريقيا', 202),
(3263, 'ar', 'جورجيا الجنوبية وجزر ساندويتش الجنوبية', 203),
(3264, 'ar', 'كوريا الجنوبية', 204),
(3265, 'ar', 'جنوب السودان', 205),
(3266, 'ar', 'إسبانيا', 206),
(3267, 'ar', 'سيريلانكا', 207),
(3268, 'ar', 'سانت بارتيليمي', 208),
(3269, 'ar', 'سانت هيلانة', 209),
(3270, 'ar', 'سانت كيتس ونيفيس', 210),
(3271, 'ar', 'شارع لوسيا', 211),
(3272, 'ar', 'سانت مارتن', 212),
(3273, 'ar', 'سانت بيير وميكلون', 213),
(3274, 'ar', 'سانت فنسنت وجزر غرينادين', 214),
(3275, 'ar', 'السودان', 215),
(3276, 'ar', 'سورينام', 216),
(3277, 'ar', 'سفالبارد وجان ماين', 217),
(3278, 'ar', 'سوازيلاند', 218),
(3279, 'ar', 'السويد', 219),
(3280, 'ar', 'سويسرا', 220),
(3281, 'ar', 'سوريا', 221),
(3282, 'ar', 'تايوان', 222),
(3283, 'ar', 'طاجيكستان', 223),
(3284, 'ar', 'تنزانيا', 224),
(3285, 'ar', 'تايلاند', 225),
(3286, 'ar', 'تيمور', 226),
(3287, 'ar', 'توجو', 227),
(3288, 'ar', 'توكيلاو', 228),
(3289, 'ar', 'تونغا', 229),
(3290, 'ar', 'ترينيداد وتوباغو', 230),
(3291, 'ar', 'تريستان دا كونها', 231),
(3292, 'ar', 'تونس', 232),
(3293, 'ar', 'ديك رومي', 233),
(3294, 'ar', 'تركمانستان', 234),
(3295, 'ar', 'جزر تركس وكايكوس', 235),
(3296, 'ar', 'توفالو', 236),
(3297, 'ar', 'جزر الولايات المتحدة البعيدة', 237),
(3298, 'ar', 'جزر فيرجن الأمريكية', 238),
(3299, 'ar', 'أوغندا', 239),
(3300, 'ar', 'أوكرانيا', 240),
(3301, 'ar', 'الإمارات العربية المتحدة', 241),
(3302, 'ar', 'المملكة المتحدة', 242),
(3303, 'ar', 'الأمم المتحدة', 243),
(3304, 'ar', 'الولايات المتحدة الأمريكية', 244),
(3305, 'ar', 'أوروغواي', 245),
(3306, 'ar', 'أوزبكستان', 246),
(3307, 'ar', 'فانواتو', 247),
(3308, 'ar', 'مدينة الفاتيكان', 248),
(3309, 'ar', 'فنزويلا', 249),
(3310, 'ar', 'فيتنام', 250),
(3311, 'ar', 'واليس وفوتونا', 251),
(3312, 'ar', 'الصحراء الغربية', 252),
(3313, 'ar', 'اليمن', 253),
(3314, 'ar', 'زامبيا', 254),
(3315, 'ar', 'زيمبابوي', 255),
(3316, 'fa', 'افغانستان', 1),
(3317, 'fa', 'جزایر الند', 2),
(3318, 'fa', 'آلبانی', 3),
(3319, 'fa', 'الجزایر', 4),
(3320, 'fa', 'ساموآ آمریکایی', 5),
(3321, 'fa', 'آندورا', 6),
(3322, 'fa', 'آنگولا', 7),
(3323, 'fa', 'آنگولا', 8),
(3324, 'fa', 'جنوبگان', 9),
(3325, 'fa', 'آنتیگوا و باربودا', 10),
(3326, 'fa', 'آرژانتین', 11),
(3327, 'fa', 'ارمنستان', 12),
(3328, 'fa', 'آروبا', 13),
(3329, 'fa', 'جزیره صعود', 14),
(3330, 'fa', 'استرالیا', 15),
(3331, 'fa', 'اتریش', 16),
(3332, 'fa', 'آذربایجان', 17),
(3333, 'fa', 'باهاما', 18),
(3334, 'fa', 'بحرین', 19),
(3335, 'fa', 'بنگلادش', 20),
(3336, 'fa', 'باربادوس', 21),
(3337, 'fa', 'بلاروس', 22),
(3338, 'fa', 'بلژیک', 23),
(3339, 'fa', 'بلژیک', 24),
(3340, 'fa', 'بنین', 25),
(3341, 'fa', 'برمودا', 26),
(3342, 'fa', 'بوتان', 27),
(3343, 'fa', 'بولیوی', 28),
(3344, 'fa', 'بوسنی و هرزگوین', 29),
(3345, 'fa', 'بوتسوانا', 30),
(3346, 'fa', 'برزیل', 31),
(3347, 'fa', 'قلمرو اقیانوس هند انگلیس', 32),
(3348, 'fa', 'جزایر ویرجین انگلیس', 33),
(3349, 'fa', 'برونئی', 34),
(3350, 'fa', 'بلغارستان', 35),
(3351, 'fa', 'بورکینا فاسو', 36),
(3352, 'fa', 'بوروندی', 37),
(3353, 'fa', 'کامبوج', 38),
(3354, 'fa', 'کامرون', 39),
(3355, 'fa', 'کانادا', 40),
(3356, 'fa', 'جزایر قناری', 41),
(3357, 'fa', 'کیپ ورد', 42),
(3358, 'fa', 'کارائیب هلند', 43),
(3359, 'fa', 'Cayman Islands', 44),
(3360, 'fa', 'جمهوری آفریقای مرکزی', 45),
(3361, 'fa', 'سوتا و ملیلا', 46),
(3362, 'fa', 'چاد', 47),
(3363, 'fa', 'شیلی', 48),
(3364, 'fa', 'چین', 49),
(3365, 'fa', 'جزیره کریسمس', 50),
(3366, 'fa', 'جزایر کوکو (Keeling)', 51),
(3367, 'fa', 'کلمبیا', 52),
(3368, 'fa', 'کومور', 53),
(3369, 'fa', 'کنگو - برزاویل', 54),
(3370, 'fa', 'کنگو - کینشاسا', 55),
(3371, 'fa', 'جزایر کوک', 56),
(3372, 'fa', 'کاستاریکا', 57),
(3373, 'fa', 'ساحل عاج', 58),
(3374, 'fa', 'کرواسی', 59),
(3375, 'fa', 'کوبا', 60),
(3376, 'fa', 'کوراسائو', 61),
(3377, 'fa', 'قبرس', 62),
(3378, 'fa', 'چک', 63),
(3379, 'fa', 'دانمارک', 64),
(3380, 'fa', 'دیگو گارسیا', 65),
(3381, 'fa', 'جیبوتی', 66),
(3382, 'fa', 'دومینیکا', 67),
(3383, 'fa', 'جمهوری دومینیکن', 68),
(3384, 'fa', 'اکوادور', 69),
(3385, 'fa', 'مصر', 70),
(3386, 'fa', 'السالوادور', 71),
(3387, 'fa', 'گینه استوایی', 72),
(3388, 'fa', 'اریتره', 73),
(3389, 'fa', 'استونی', 74),
(3390, 'fa', 'اتیوپی', 75),
(3391, 'fa', 'منطقه یورو', 76),
(3392, 'fa', 'جزایر فالکلند', 77),
(3393, 'fa', 'جزایر فارو', 78),
(3394, 'fa', 'فیجی', 79),
(3395, 'fa', 'فنلاند', 80),
(3396, 'fa', 'فرانسه', 81),
(3397, 'fa', 'گویان فرانسه', 82),
(3398, 'fa', 'پلی‌نزی فرانسه', 83),
(3399, 'fa', 'سرزمین های جنوبی فرانسه', 84),
(3400, 'fa', 'گابن', 85),
(3401, 'fa', 'گامبیا', 86),
(3402, 'fa', 'جورجیا', 87),
(3403, 'fa', 'آلمان', 88),
(3404, 'fa', 'غنا', 89),
(3405, 'fa', 'جبل الطارق', 90),
(3406, 'fa', 'یونان', 91),
(3407, 'fa', 'گرینلند', 92),
(3408, 'fa', 'گرنادا', 93),
(3409, 'fa', 'گوادلوپ', 94),
(3410, 'fa', 'گوام', 95),
(3411, 'fa', 'گواتمالا', 96),
(3412, 'fa', 'گورنسی', 97),
(3413, 'fa', 'گینه', 98),
(3414, 'fa', 'گینه بیسائو', 99),
(3415, 'fa', 'گویان', 100),
(3416, 'fa', 'هائیتی', 101),
(3417, 'fa', 'هندوراس', 102),
(3418, 'fa', 'هنگ کنگ SAR چین', 103),
(3419, 'fa', 'مجارستان', 104),
(3420, 'fa', 'ایسلند', 105),
(3421, 'fa', 'هند', 106),
(3422, 'fa', 'اندونزی', 107),
(3423, 'fa', 'ایران', 108),
(3424, 'fa', 'عراق', 109),
(3425, 'fa', 'ایرلند', 110),
(3426, 'fa', 'جزیره من', 111),
(3427, 'fa', 'اسرائيل', 112),
(3428, 'fa', 'ایتالیا', 113),
(3429, 'fa', 'جامائیکا', 114),
(3430, 'fa', 'ژاپن', 115),
(3431, 'fa', 'پیراهن ورزشی', 116),
(3432, 'fa', 'اردن', 117),
(3433, 'fa', 'قزاقستان', 118),
(3434, 'fa', 'کنیا', 119),
(3435, 'fa', 'کیریباتی', 120),
(3436, 'fa', 'کوزوو', 121),
(3437, 'fa', 'کویت', 122),
(3438, 'fa', 'قرقیزستان', 123),
(3439, 'fa', 'لائوس', 124),
(3440, 'fa', 'لتونی', 125),
(3441, 'fa', 'لبنان', 126),
(3442, 'fa', 'لسوتو', 127),
(3443, 'fa', 'لیبریا', 128),
(3444, 'fa', 'لیبی', 129),
(3445, 'fa', 'لیختن اشتاین', 130),
(3446, 'fa', 'لیتوانی', 131),
(3447, 'fa', 'لوکزامبورگ', 132),
(3448, 'fa', 'ماکائو SAR چین', 133),
(3449, 'fa', 'مقدونیه', 134),
(3450, 'fa', 'ماداگاسکار', 135),
(3451, 'fa', 'مالاوی', 136),
(3452, 'fa', 'مالزی', 137),
(3453, 'fa', 'مالدیو', 138),
(3454, 'fa', 'مالی', 139),
(3455, 'fa', 'مالت', 140),
(3456, 'fa', 'جزایر مارشال', 141),
(3457, 'fa', 'مارتینیک', 142),
(3458, 'fa', 'موریتانی', 143),
(3459, 'fa', 'موریس', 144),
(3460, 'fa', 'گمشده', 145),
(3461, 'fa', 'مکزیک', 146),
(3462, 'fa', 'میکرونزی', 147),
(3463, 'fa', 'مولداوی', 148),
(3464, 'fa', 'موناکو', 149),
(3465, 'fa', 'مغولستان', 150),
(3466, 'fa', 'مونته نگرو', 151),
(3467, 'fa', 'مونتسرات', 152),
(3468, 'fa', 'مراکش', 153),
(3469, 'fa', 'موزامبیک', 154),
(3470, 'fa', 'میانمار (برمه)', 155),
(3471, 'fa', 'ناميبيا', 156),
(3472, 'fa', 'نائورو', 157),
(3473, 'fa', 'نپال', 158),
(3474, 'fa', 'هلند', 159),
(3475, 'fa', 'کالدونیای جدید', 160),
(3476, 'fa', 'نیوزلند', 161),
(3477, 'fa', 'نیکاراگوئه', 162),
(3478, 'fa', 'نیجر', 163),
(3479, 'fa', 'نیجریه', 164),
(3480, 'fa', 'نیو', 165),
(3481, 'fa', 'جزیره نورفولک', 166),
(3482, 'fa', 'کره شمالی', 167),
(3483, 'fa', 'جزایر ماریانای شمالی', 168),
(3484, 'fa', 'نروژ', 169),
(3485, 'fa', 'عمان', 170),
(3486, 'fa', 'پاکستان', 171),
(3487, 'fa', 'پالائو', 172),
(3488, 'fa', 'سرزمین های فلسطینی', 173),
(3489, 'fa', 'پاناما', 174),
(3490, 'fa', 'پاپوا گینه نو', 175),
(3491, 'fa', 'پاراگوئه', 176),
(3492, 'fa', 'پرو', 177),
(3493, 'fa', 'فیلیپین', 178),
(3494, 'fa', 'جزایر پیکریرن', 179),
(3495, 'fa', 'لهستان', 180),
(3496, 'fa', 'کشور پرتغال', 181),
(3497, 'fa', 'پورتوریکو', 182),
(3498, 'fa', 'قطر', 183),
(3499, 'fa', 'تجدید دیدار', 184),
(3500, 'fa', 'رومانی', 185),
(3501, 'fa', 'روسیه', 186),
(3502, 'fa', 'رواندا', 187),
(3503, 'fa', 'ساموآ', 188),
(3504, 'fa', 'سان مارینو', 189),
(3505, 'fa', 'سنت کیتس و نوویس', 190),
(3506, 'fa', 'عربستان سعودی', 191),
(3507, 'fa', 'سنگال', 192),
(3508, 'fa', 'صربستان', 193),
(3509, 'fa', 'سیشل', 194),
(3510, 'fa', 'سیرالئون', 195),
(3511, 'fa', 'سنگاپور', 196),
(3512, 'fa', 'سینت ماارتن', 197),
(3513, 'fa', 'اسلواکی', 198),
(3514, 'fa', 'اسلوونی', 199),
(3515, 'fa', 'جزایر سلیمان', 200),
(3516, 'fa', 'سومالی', 201),
(3517, 'fa', 'آفریقای جنوبی', 202),
(3518, 'fa', 'جزایر جورجیا جنوبی و جزایر ساندویچ جنوبی', 203),
(3519, 'fa', 'کره جنوبی', 204),
(3520, 'fa', 'سودان جنوبی', 205),
(3521, 'fa', 'اسپانیا', 206),
(3522, 'fa', 'سری لانکا', 207),
(3523, 'fa', 'سنت بارتلی', 208),
(3524, 'fa', 'سنت هلنا', 209),
(3525, 'fa', 'سنت کیتز و نوویس', 210),
(3526, 'fa', 'سنت لوسیا', 211),
(3527, 'fa', 'سنت مارتین', 212),
(3528, 'fa', 'سنت پیر و میکلون', 213),
(3529, 'fa', 'سنت وینسنت و گرنادینها', 214),
(3530, 'fa', 'سودان', 215),
(3531, 'fa', 'سورینام', 216),
(3532, 'fa', 'اسوالبارد و جان ماین', 217),
(3533, 'fa', 'سوازیلند', 218),
(3534, 'fa', 'سوئد', 219),
(3535, 'fa', 'سوئیس', 220),
(3536, 'fa', 'سوریه', 221),
(3537, 'fa', 'تایوان', 222),
(3538, 'fa', 'تاجیکستان', 223),
(3539, 'fa', 'تانزانیا', 224),
(3540, 'fa', 'تایلند', 225),
(3541, 'fa', 'تیمور-لست', 226),
(3542, 'fa', 'رفتن', 227),
(3543, 'fa', 'توکلو', 228),
(3544, 'fa', 'تونگا', 229),
(3545, 'fa', 'ترینیداد و توباگو', 230),
(3546, 'fa', 'تریستان دا کانونا', 231),
(3547, 'fa', 'تونس', 232),
(3548, 'fa', 'بوقلمون', 233),
(3549, 'fa', 'ترکمنستان', 234),
(3550, 'fa', 'جزایر تورکس و کایکوس', 235),
(3551, 'fa', 'تووالو', 236),
(3552, 'fa', 'جزایر دور افتاده ایالات متحده آمریکا', 237),
(3553, 'fa', 'جزایر ویرجین ایالات متحده', 238),
(3554, 'fa', 'اوگاندا', 239),
(3555, 'fa', 'اوکراین', 240),
(3556, 'fa', 'امارات متحده عربی', 241),
(3557, 'fa', 'انگلستان', 242),
(3558, 'fa', 'سازمان ملل', 243),
(3559, 'fa', 'ایالات متحده', 244),
(3560, 'fa', 'اروگوئه', 245),
(3561, 'fa', 'ازبکستان', 246),
(3562, 'fa', 'وانواتو', 247),
(3563, 'fa', 'شهر واتیکان', 248),
(3564, 'fa', 'ونزوئلا', 249),
(3565, 'fa', 'ویتنام', 250),
(3566, 'fa', 'والیس و فوتونا', 251),
(3567, 'fa', 'صحرای غربی', 252),
(3568, 'fa', 'یمن', 253),
(3569, 'fa', 'زامبیا', 254),
(3570, 'fa', 'زیمبابوه', 255),
(3571, 'pt_BR', 'Afeganistão', 1),
(3572, 'pt_BR', 'Ilhas Åland', 2),
(3573, 'pt_BR', 'Albânia', 3),
(3574, 'pt_BR', 'Argélia', 4),
(3575, 'pt_BR', 'Samoa Americana', 5),
(3576, 'pt_BR', 'Andorra', 6),
(3577, 'pt_BR', 'Angola', 7),
(3578, 'pt_BR', 'Angola', 8),
(3579, 'pt_BR', 'Antártico', 9),
(3580, 'pt_BR', 'Antígua e Barbuda', 10),
(3581, 'pt_BR', 'Argentina', 11),
(3582, 'pt_BR', 'Armênia', 12),
(3583, 'pt_BR', 'Aruba', 13),
(3584, 'pt_BR', 'Ilha de escalada', 14),
(3585, 'pt_BR', 'Austrália', 15),
(3586, 'pt_BR', 'Áustria', 16),
(3587, 'pt_BR', 'Azerbaijão', 17),
(3588, 'pt_BR', 'Bahamas', 18),
(3589, 'pt_BR', 'Bahrain', 19),
(3590, 'pt_BR', 'Bangladesh', 20),
(3591, 'pt_BR', 'Barbados', 21),
(3592, 'pt_BR', 'Bielorrússia', 22),
(3593, 'pt_BR', 'Bélgica', 23),
(3594, 'pt_BR', 'Bélgica', 24),
(3595, 'pt_BR', 'Benin', 25),
(3596, 'pt_BR', 'Bermuda', 26),
(3597, 'pt_BR', 'Butão', 27),
(3598, 'pt_BR', 'Bolívia', 28),
(3599, 'pt_BR', 'Bósnia e Herzegovina', 29),
(3600, 'pt_BR', 'Botsuana', 30),
(3601, 'pt_BR', 'Brasil', 31),
(3602, 'pt_BR', 'Território Britânico do Oceano Índico', 32),
(3603, 'pt_BR', 'Ilhas Virgens Britânicas', 33),
(3604, 'pt_BR', 'Brunei', 34),
(3605, 'pt_BR', 'Bulgária', 35),
(3606, 'pt_BR', 'Burkina Faso', 36),
(3607, 'pt_BR', 'Burundi', 37),
(3608, 'pt_BR', 'Camboja', 38),
(3609, 'pt_BR', 'Camarões', 39),
(3610, 'pt_BR', 'Canadá', 40),
(3611, 'pt_BR', 'Ilhas Canárias', 41),
(3612, 'pt_BR', 'Cabo Verde', 42),
(3613, 'pt_BR', 'Holanda do Caribe', 43),
(3614, 'pt_BR', 'Ilhas Cayman', 44),
(3615, 'pt_BR', 'República Centro-Africana', 45),
(3616, 'pt_BR', 'Ceuta e Melilla', 46),
(3617, 'pt_BR', 'Chade', 47),
(3618, 'pt_BR', 'Chile', 48),
(3619, 'pt_BR', 'China', 49),
(3620, 'pt_BR', 'Ilha Christmas', 50),
(3621, 'pt_BR', 'Ilhas Cocos (Keeling)', 51),
(3622, 'pt_BR', 'Colômbia', 52),
(3623, 'pt_BR', 'Comores', 53),
(3624, 'pt_BR', 'Congo - Brazzaville', 54),
(3625, 'pt_BR', 'Congo - Kinshasa', 55),
(3626, 'pt_BR', 'Ilhas Cook', 56),
(3627, 'pt_BR', 'Costa Rica', 57),
(3628, 'pt_BR', 'Costa do Marfim', 58),
(3629, 'pt_BR', 'Croácia', 59),
(3630, 'pt_BR', 'Cuba', 60),
(3631, 'pt_BR', 'Curaçao', 61),
(3632, 'pt_BR', 'Chipre', 62),
(3633, 'pt_BR', 'Czechia', 63),
(3634, 'pt_BR', 'Dinamarca', 64),
(3635, 'pt_BR', 'Diego Garcia', 65),
(3636, 'pt_BR', 'Djibuti', 66),
(3637, 'pt_BR', 'Dominica', 67),
(3638, 'pt_BR', 'República Dominicana', 68),
(3639, 'pt_BR', 'Equador', 69),
(3640, 'pt_BR', 'Egito', 70),
(3641, 'pt_BR', 'El Salvador', 71),
(3642, 'pt_BR', 'Guiné Equatorial', 72),
(3643, 'pt_BR', 'Eritreia', 73),
(3644, 'pt_BR', 'Estônia', 74),
(3645, 'pt_BR', 'Etiópia', 75),
(3646, 'pt_BR', 'Zona Euro', 76),
(3647, 'pt_BR', 'Ilhas Malvinas', 77),
(3648, 'pt_BR', 'Ilhas Faroe', 78),
(3649, 'pt_BR', 'Fiji', 79),
(3650, 'pt_BR', 'Finlândia', 80),
(3651, 'pt_BR', 'França', 81),
(3652, 'pt_BR', 'Guiana Francesa', 82),
(3653, 'pt_BR', 'Polinésia Francesa', 83),
(3654, 'pt_BR', 'Territórios Franceses do Sul', 84),
(3655, 'pt_BR', 'Gabão', 85),
(3656, 'pt_BR', 'Gâmbia', 86),
(3657, 'pt_BR', 'Geórgia', 87),
(3658, 'pt_BR', 'Alemanha', 88),
(3659, 'pt_BR', 'Gana', 89),
(3660, 'pt_BR', 'Gibraltar', 90),
(3661, 'pt_BR', 'Grécia', 91),
(3662, 'pt_BR', 'Gronelândia', 92),
(3663, 'pt_BR', 'Granada', 93),
(3664, 'pt_BR', 'Guadalupe', 94),
(3665, 'pt_BR', 'Guam', 95),
(3666, 'pt_BR', 'Guatemala', 96),
(3667, 'pt_BR', 'Guernsey', 97),
(3668, 'pt_BR', 'Guiné', 98),
(3669, 'pt_BR', 'Guiné-Bissau', 99),
(3670, 'pt_BR', 'Guiana', 100),
(3671, 'pt_BR', 'Haiti', 101),
(3672, 'pt_BR', 'Honduras', 102),
(3673, 'pt_BR', 'Região Administrativa Especial de Hong Kong, China', 103),
(3674, 'pt_BR', 'Hungria', 104),
(3675, 'pt_BR', 'Islândia', 105),
(3676, 'pt_BR', 'Índia', 106),
(3677, 'pt_BR', 'Indonésia', 107),
(3678, 'pt_BR', 'Irã', 108),
(3679, 'pt_BR', 'Iraque', 109),
(3680, 'pt_BR', 'Irlanda', 110),
(3681, 'pt_BR', 'Ilha de Man', 111),
(3682, 'pt_BR', 'Israel', 112),
(3683, 'pt_BR', 'Itália', 113),
(3684, 'pt_BR', 'Jamaica', 114),
(3685, 'pt_BR', 'Japão', 115),
(3686, 'pt_BR', 'Jersey', 116),
(3687, 'pt_BR', 'Jordânia', 117),
(3688, 'pt_BR', 'Cazaquistão', 118),
(3689, 'pt_BR', 'Quênia', 119),
(3690, 'pt_BR', 'Quiribati', 120),
(3691, 'pt_BR', 'Kosovo', 121),
(3692, 'pt_BR', 'Kuwait', 122),
(3693, 'pt_BR', 'Quirguistão', 123),
(3694, 'pt_BR', 'Laos', 124),
(3695, 'pt_BR', 'Letônia', 125),
(3696, 'pt_BR', 'Líbano', 126),
(3697, 'pt_BR', 'Lesoto', 127),
(3698, 'pt_BR', 'Libéria', 128),
(3699, 'pt_BR', 'Líbia', 129),
(3700, 'pt_BR', 'Liechtenstein', 130),
(3701, 'pt_BR', 'Lituânia', 131),
(3702, 'pt_BR', 'Luxemburgo', 132),
(3703, 'pt_BR', 'Macau SAR China', 133),
(3704, 'pt_BR', 'Macedônia', 134),
(3705, 'pt_BR', 'Madagascar', 135),
(3706, 'pt_BR', 'Malawi', 136),
(3707, 'pt_BR', 'Malásia', 137),
(3708, 'pt_BR', 'Maldivas', 138),
(3709, 'pt_BR', 'Mali', 139),
(3710, 'pt_BR', 'Malta', 140),
(3711, 'pt_BR', 'Ilhas Marshall', 141),
(3712, 'pt_BR', 'Martinica', 142),
(3713, 'pt_BR', 'Mauritânia', 143),
(3714, 'pt_BR', 'Maurício', 144),
(3715, 'pt_BR', 'Maiote', 145),
(3716, 'pt_BR', 'México', 146),
(3717, 'pt_BR', 'Micronésia', 147),
(3718, 'pt_BR', 'Moldávia', 148),
(3719, 'pt_BR', 'Mônaco', 149),
(3720, 'pt_BR', 'Mongólia', 150),
(3721, 'pt_BR', 'Montenegro', 151),
(3722, 'pt_BR', 'Montserrat', 152),
(3723, 'pt_BR', 'Marrocos', 153),
(3724, 'pt_BR', 'Moçambique', 154),
(3725, 'pt_BR', 'Mianmar (Birmânia)', 155),
(3726, 'pt_BR', 'Namíbia', 156),
(3727, 'pt_BR', 'Nauru', 157),
(3728, 'pt_BR', 'Nepal', 158),
(3729, 'pt_BR', 'Holanda', 159),
(3730, 'pt_BR', 'Nova Caledônia', 160),
(3731, 'pt_BR', 'Nova Zelândia', 161),
(3732, 'pt_BR', 'Nicarágua', 162),
(3733, 'pt_BR', 'Níger', 163),
(3734, 'pt_BR', 'Nigéria', 164),
(3735, 'pt_BR', 'Niue', 165),
(3736, 'pt_BR', 'Ilha Norfolk', 166),
(3737, 'pt_BR', 'Coréia do Norte', 167),
(3738, 'pt_BR', 'Ilhas Marianas do Norte', 168),
(3739, 'pt_BR', 'Noruega', 169),
(3740, 'pt_BR', 'Omã', 170),
(3741, 'pt_BR', 'Paquistão', 171),
(3742, 'pt_BR', 'Palau', 172),
(3743, 'pt_BR', 'Territórios Palestinos', 173),
(3744, 'pt_BR', 'Panamá', 174),
(3745, 'pt_BR', 'Papua Nova Guiné', 175),
(3746, 'pt_BR', 'Paraguai', 176),
(3747, 'pt_BR', 'Peru', 177),
(3748, 'pt_BR', 'Filipinas', 178),
(3749, 'pt_BR', 'Ilhas Pitcairn', 179),
(3750, 'pt_BR', 'Polônia', 180),
(3751, 'pt_BR', 'Portugal', 181),
(3752, 'pt_BR', 'Porto Rico', 182),
(3753, 'pt_BR', 'Catar', 183),
(3754, 'pt_BR', 'Reunião', 184),
(3755, 'pt_BR', 'Romênia', 185),
(3756, 'pt_BR', 'Rússia', 186),
(3757, 'pt_BR', 'Ruanda', 187),
(3758, 'pt_BR', 'Samoa', 188),
(3759, 'pt_BR', 'São Marinho', 189),
(3760, 'pt_BR', 'São Cristóvão e Nevis', 190),
(3761, 'pt_BR', 'Arábia Saudita', 191),
(3762, 'pt_BR', 'Senegal', 192),
(3763, 'pt_BR', 'Sérvia', 193),
(3764, 'pt_BR', 'Seychelles', 194),
(3765, 'pt_BR', 'Serra Leoa', 195),
(3766, 'pt_BR', 'Cingapura', 196),
(3767, 'pt_BR', 'São Martinho', 197),
(3768, 'pt_BR', 'Eslováquia', 198),
(3769, 'pt_BR', 'Eslovênia', 199),
(3770, 'pt_BR', 'Ilhas Salomão', 200),
(3771, 'pt_BR', 'Somália', 201),
(3772, 'pt_BR', 'África do Sul', 202),
(3773, 'pt_BR', 'Ilhas Geórgia do Sul e Sandwich do Sul', 203),
(3774, 'pt_BR', 'Coréia do Sul', 204),
(3775, 'pt_BR', 'Sudão do Sul', 205),
(3776, 'pt_BR', 'Espanha', 206),
(3777, 'pt_BR', 'Sri Lanka', 207),
(3778, 'pt_BR', 'São Bartolomeu', 208),
(3779, 'pt_BR', 'Santa Helena', 209),
(3780, 'pt_BR', 'São Cristóvão e Nevis', 210),
(3781, 'pt_BR', 'Santa Lúcia', 211),
(3782, 'pt_BR', 'São Martinho', 212),
(3783, 'pt_BR', 'São Pedro e Miquelon', 213),
(3784, 'pt_BR', 'São Vicente e Granadinas', 214),
(3785, 'pt_BR', 'Sudão', 215),
(3786, 'pt_BR', 'Suriname', 216),
(3787, 'pt_BR', 'Svalbard e Jan Mayen', 217),
(3788, 'pt_BR', 'Suazilândia', 218),
(3789, 'pt_BR', 'Suécia', 219),
(3790, 'pt_BR', 'Suíça', 220),
(3791, 'pt_BR', 'Síria', 221),
(3792, 'pt_BR', 'Taiwan', 222),
(3793, 'pt_BR', 'Tajiquistão', 223),
(3794, 'pt_BR', 'Tanzânia', 224),
(3795, 'pt_BR', 'Tailândia', 225),
(3796, 'pt_BR', 'Timor-Leste', 226),
(3797, 'pt_BR', 'Togo', 227),
(3798, 'pt_BR', 'Tokelau', 228),
(3799, 'pt_BR', 'Tonga', 229),
(3800, 'pt_BR', 'Trinidad e Tobago', 230),
(3801, 'pt_BR', 'Tristan da Cunha', 231),
(3802, 'pt_BR', 'Tunísia', 232),
(3803, 'pt_BR', 'Turquia', 233),
(3804, 'pt_BR', 'Turquemenistão', 234),
(3805, 'pt_BR', 'Ilhas Turks e Caicos', 235),
(3806, 'pt_BR', 'Tuvalu', 236),
(3807, 'pt_BR', 'Ilhas periféricas dos EUA', 237),
(3808, 'pt_BR', 'Ilhas Virgens dos EUA', 238),
(3809, 'pt_BR', 'Uganda', 239),
(3810, 'pt_BR', 'Ucrânia', 240),
(3811, 'pt_BR', 'Emirados Árabes Unidos', 241),
(3812, 'pt_BR', 'Reino Unido', 242),
(3813, 'pt_BR', 'Nações Unidas', 243),
(3814, 'pt_BR', 'Estados Unidos', 244),
(3815, 'pt_BR', 'Uruguai', 245),
(3816, 'pt_BR', 'Uzbequistão', 246),
(3817, 'pt_BR', 'Vanuatu', 247),
(3818, 'pt_BR', 'Cidade do Vaticano', 248),
(3819, 'pt_BR', 'Venezuela', 249),
(3820, 'pt_BR', 'Vietnã', 250),
(3821, 'pt_BR', 'Wallis e Futuna', 251),
(3822, 'pt_BR', 'Saara Ocidental', 252),
(3823, 'pt_BR', 'Iêmen', 253),
(3824, 'pt_BR', 'Zâmbia', 254),
(3825, 'pt_BR', 'Zimbábue', 255);

-- --------------------------------------------------------

--
-- Structure de la table `currencies`
--

DROP TABLE IF EXISTS `currencies`;
CREATE TABLE IF NOT EXISTS `currencies` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `symbol` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `currencies`
--

INSERT INTO `currencies` (`id`, `code`, `name`, `created_at`, `updated_at`, `symbol`) VALUES
(1, 'USD', 'US Dollar', NULL, NULL, '$'),
(2, 'EUR', 'Euro', NULL, NULL, '€');

-- --------------------------------------------------------

--
-- Structure de la table `currency_exchange_rates`
--

DROP TABLE IF EXISTS `currency_exchange_rates`;
CREATE TABLE IF NOT EXISTS `currency_exchange_rates` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `rate` decimal(24,12) NOT NULL,
  `target_currency` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `currency_exchange_rates_target_currency_unique` (`target_currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `customers`
--

DROP TABLE IF EXISTS `customers`;
CREATE TABLE IF NOT EXISTS `customers` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `password` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_token` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_group_id` int UNSIGNED DEFAULT NULL,
  `subscribed_to_news_letter` tinyint(1) NOT NULL DEFAULT '0',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `phone` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customers_email_unique` (`email`),
  UNIQUE KEY `customers_api_token_unique` (`api_token`),
  KEY `customers_customer_group_id_foreign` (`customer_group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `customers`
--

INSERT INTO `customers` (`id`, `first_name`, `last_name`, `gender`, `date_of_birth`, `email`, `status`, `password`, `api_token`, `customer_group_id`, `subscribed_to_news_letter`, `remember_token`, `created_at`, `updated_at`, `is_verified`, `token`, `notes`, `phone`) VALUES
(1, 'calixte', 'marchand', 'Male', '1970-11-30', 'cmarchand@netysoft.com', 1, '$2y$10$P6Ta03sqwSld1sNtDaF/QekXmYWdlVDSzsrXVMzS9kq6/iLF5woK6', 'kTtcVtREXg7oZrMx95olrF52Gy92G8ToxzaVtkWebtaTfAiOZNbBxD7untKtw788BmPSSszWDR7ddbbe', 2, 0, NULL, '2020-09-22 07:27:17', '2020-09-22 19:16:49', 1, '2706032127b01c9e36125618cc44006a', NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `customer_documents`
--

DROP TABLE IF EXISTS `customer_documents`;
CREATE TABLE IF NOT EXISTS `customer_documents` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_id` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `customer_groups`
--

DROP TABLE IF EXISTS `customer_groups`;
CREATE TABLE IF NOT EXISTS `customer_groups` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_user_defined` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `position` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customer_groups_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `customer_groups`
--

INSERT INTO `customer_groups` (`id`, `name`, `is_user_defined`, `created_at`, `updated_at`, `code`, `position`) VALUES
(1, 'Invité', 0, NULL, '2020-09-27 15:14:29', 'Invite', NULL),
(2, 'Caviste', 0, NULL, '2020-09-27 15:15:36', 'Caviste', 1),
(3, 'Grossiste', 0, NULL, '2020-09-27 15:15:09', 'Grossiste', 4),
(4, 'Restaurateur', 1, '2020-09-27 15:16:00', '2020-09-27 15:16:00', 'Restaurateur', 2),
(5, 'Acheteur grande distribution', 1, '2020-09-27 15:16:49', '2020-09-27 15:16:49', 'Acheteur_grande_distribution', 3),
(6, 'Importateur/Exportateur', 1, '2020-09-27 15:20:25', '2020-09-27 15:20:25', 'Importateur_exportateur', 5);

-- --------------------------------------------------------

--
-- Structure de la table `customer_password_resets`
--

DROP TABLE IF EXISTS `customer_password_resets`;
CREATE TABLE IF NOT EXISTS `customer_password_resets` (
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `customer_password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `downloadable_link_purchased`
--

DROP TABLE IF EXISTS `downloadable_link_purchased`;
CREATE TABLE IF NOT EXISTS `downloadable_link_purchased` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `download_bought` int NOT NULL DEFAULT '0',
  `download_used` int NOT NULL DEFAULT '0',
  `status` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_id` int UNSIGNED NOT NULL,
  `order_id` int UNSIGNED NOT NULL,
  `order_item_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `downloadable_link_purchased_customer_id_foreign` (`customer_id`),
  KEY `downloadable_link_purchased_order_id_foreign` (`order_id`),
  KEY `downloadable_link_purchased_order_item_id_foreign` (`order_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `inventory_sources`
--

DROP TABLE IF EXISTS `inventory_sources`;
CREATE TABLE IF NOT EXISTS `inventory_sources` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `contact_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_number` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_fax` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `street` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `postcode` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` int NOT NULL DEFAULT '0',
  `latitude` decimal(10,5) DEFAULT NULL,
  `longitude` decimal(10,5) DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `inventory_sources_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `inventory_sources`
--

INSERT INTO `inventory_sources` (`id`, `code`, `name`, `description`, `contact_name`, `contact_email`, `contact_number`, `contact_fax`, `country`, `state`, `city`, `street`, `postcode`, `priority`, `latitude`, `longitude`, `status`, `created_at`, `updated_at`) VALUES
(1, 'entrepot_paris', 'Entrepot paris', NULL, 'Detroit Warehouse', 'warehouse@example.com', '1234567899', NULL, 'US', 'MI', 'Detroit', '12th Street', '48127', 0, NULL, NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
CREATE TABLE IF NOT EXISTS `invoices` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `increment_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_sent` tinyint(1) NOT NULL DEFAULT '0',
  `total_qty` int DEFAULT NULL,
  `base_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sub_total` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total` decimal(12,4) DEFAULT '0.0000',
  `grand_total` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total` decimal(12,4) DEFAULT '0.0000',
  `shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `order_id` int UNSIGNED DEFAULT NULL,
  `order_address_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `transaction_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `invoices_order_id_foreign` (`order_id`),
  KEY `invoices_order_address_id_foreign` (`order_address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `invoice_items`
--

DROP TABLE IF EXISTS `invoice_items`;
CREATE TABLE IF NOT EXISTS `invoice_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sku` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qty` int DEFAULT NULL,
  `price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `total` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_total` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `product_id` int UNSIGNED DEFAULT NULL,
  `product_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_item_id` int UNSIGNED DEFAULT NULL,
  `invoice_id` int UNSIGNED DEFAULT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `additional` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `discount_percent` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  PRIMARY KEY (`id`),
  KEY `invoice_items_invoice_id_foreign` (`invoice_id`),
  KEY `invoice_items_parent_id_foreign` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `locales`
--

DROP TABLE IF EXISTS `locales`;
CREATE TABLE IF NOT EXISTS `locales` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `direction` enum('ltr','rtl') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ltr',
  `locale_image` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `locales_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `locales`
--

INSERT INTO `locales` (`id`, `code`, `name`, `created_at`, `updated_at`, `direction`, `locale_image`) VALUES
(1, 'en', 'English', NULL, NULL, 'ltr', NULL),
(2, 'fr', 'French', NULL, NULL, 'ltr', NULL),
(3, 'nl', 'Dutch', NULL, NULL, 'ltr', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_bulkupload_admin_dataflowprofile`
--

DROP TABLE IF EXISTS `marketplace_bulkupload_admin_dataflowprofile`;
CREATE TABLE IF NOT EXISTS `marketplace_bulkupload_admin_dataflowprofile` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attribute_family_id` int UNSIGNED NOT NULL,
  `seller_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mp_bulkupload_admin_foreign_attribute_family_id` (`attribute_family_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_bulkupload_dataflowprofile`
--

DROP TABLE IF EXISTS `marketplace_bulkupload_dataflowprofile`;
CREATE TABLE IF NOT EXISTS `marketplace_bulkupload_dataflowprofile` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `profile_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attribute_family_id` int UNSIGNED NOT NULL,
  `is_seller` tinyint(1) NOT NULL DEFAULT '0',
  `run_status` tinyint(1) NOT NULL DEFAULT '0',
  `seller_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mp_bulkupload_foreign_attribute_family_id` (`attribute_family_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_import_new_products`
--

DROP TABLE IF EXISTS `marketplace_import_new_products`;
CREATE TABLE IF NOT EXISTS `marketplace_import_new_products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attribute_family_id` int UNSIGNED NOT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_flow_profile_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mp_import_foreign_attribute_family_id` (`attribute_family_id`),
  KEY `marketplace_import_new_products_data_flow_profile_id_foreign` (`data_flow_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `marketplace_import_new_products_by_admin`
--

DROP TABLE IF EXISTS `marketplace_import_new_products_by_admin`;
CREATE TABLE IF NOT EXISTS `marketplace_import_new_products_by_admin` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attribute_family_id` int UNSIGNED NOT NULL,
  `data_flow_profile_id` int UNSIGNED NOT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mp_import_admin_foreign_attribute_family_id` (`attribute_family_id`),
  KEY `mp_import_admin_foreign_data_flow_profile_id` (`data_flow_profile_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=211 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_admin_password_resets_table', 1),
(3, '2014_10_12_100000_create_password_resets_table', 1),
(4, '2018_06_12_111907_create_admins_table', 1),
(5, '2018_06_13_055341_create_roles_table', 1),
(6, '2018_07_05_130148_create_attributes_table', 1),
(7, '2018_07_05_132854_create_attribute_translations_table', 1),
(8, '2018_07_05_135150_create_attribute_families_table', 1),
(9, '2018_07_05_135152_create_attribute_groups_table', 1),
(10, '2018_07_05_140832_create_attribute_options_table', 1),
(11, '2018_07_05_140856_create_attribute_option_translations_table', 1),
(12, '2018_07_05_142820_create_categories_table', 1),
(13, '2018_07_10_055143_create_locales_table', 1),
(14, '2018_07_20_054426_create_countries_table', 1),
(15, '2018_07_20_054502_create_currencies_table', 1),
(16, '2018_07_20_054542_create_currency_exchange_rates_table', 1),
(17, '2018_07_20_064849_create_channels_table', 1),
(18, '2018_07_21_142836_create_category_translations_table', 1),
(19, '2018_07_23_110040_create_inventory_sources_table', 1),
(20, '2018_07_24_082635_create_customer_groups_table', 1),
(21, '2018_07_24_082930_create_customers_table', 1),
(22, '2018_07_24_083025_create_customer_addresses_table', 1),
(23, '2018_07_27_065727_create_products_table', 1),
(24, '2018_07_27_070011_create_product_attribute_values_table', 1),
(25, '2018_07_27_092623_create_product_reviews_table', 1),
(26, '2018_07_27_113941_create_product_images_table', 1),
(27, '2018_07_27_113956_create_product_inventories_table', 1),
(28, '2018_08_03_114203_create_sliders_table', 1),
(29, '2018_08_30_064755_create_tax_categories_table', 1),
(30, '2018_08_30_065042_create_tax_rates_table', 1),
(31, '2018_08_30_065840_create_tax_mappings_table', 1),
(32, '2018_09_05_150444_create_cart_table', 1),
(33, '2018_09_05_150915_create_cart_items_table', 1),
(34, '2018_09_11_064045_customer_password_resets', 1),
(35, '2018_09_19_092845_create_cart_address', 1),
(36, '2018_09_19_093453_create_cart_payment', 1),
(37, '2018_09_19_093508_create_cart_shipping_rates_table', 1),
(38, '2018_09_20_060658_create_core_config_table', 1),
(39, '2018_09_27_113154_create_orders_table', 1),
(40, '2018_09_27_113207_create_order_items_table', 1),
(41, '2018_09_27_113405_create_order_address_table', 1),
(42, '2018_09_27_115022_create_shipments_table', 1),
(43, '2018_09_27_115029_create_shipment_items_table', 1),
(44, '2018_09_27_115135_create_invoices_table', 1),
(45, '2018_09_27_115144_create_invoice_items_table', 1),
(46, '2018_10_01_095504_create_order_payment_table', 1),
(47, '2018_10_03_025230_create_wishlist_table', 1),
(48, '2018_10_12_101803_create_country_translations_table', 1),
(49, '2018_10_12_101913_create_country_states_table', 1),
(50, '2018_10_12_101923_create_country_state_translations_table', 1),
(51, '2018_11_15_153257_alter_order_table', 1),
(52, '2018_11_15_163729_alter_invoice_table', 1),
(53, '2018_11_16_173504_create_subscribers_list_table', 1),
(54, '2018_11_17_165758_add_is_verified_column_in_customers_table', 1),
(55, '2018_11_21_144411_create_cart_item_inventories_table', 1),
(56, '2018_11_26_110500_change_gender_column_in_customers_table', 1),
(57, '2018_11_27_174449_change_content_column_in_sliders_table', 1),
(58, '2018_12_05_132625_drop_foreign_key_core_config_table', 1),
(59, '2018_12_05_132629_alter_core_config_table', 1),
(60, '2018_12_06_185202_create_product_flat_table', 1),
(61, '2018_12_21_101307_alter_channels_table', 1),
(62, '2018_12_24_123812_create_channel_inventory_sources_table', 1),
(63, '2018_12_24_184402_alter_shipments_table', 1),
(64, '2018_12_26_165327_create_product_ordered_inventories_table', 1),
(65, '2018_12_31_161114_alter_channels_category_table', 1),
(66, '2019_01_11_122452_add_vendor_id_column_in_product_inventories_table', 1),
(67, '2019_01_25_124522_add_updated_at_column_in_product_flat_table', 1),
(68, '2019_01_29_123053_add_min_price_and_max_price_column_in_product_flat_table', 1),
(69, '2019_01_31_164117_update_value_column_type_to_text_in_core_config_table', 1),
(70, '2019_02_21_145238_alter_product_reviews_table', 1),
(71, '2019_02_21_152709_add_swatch_type_column_in_attributes_table', 1),
(72, '2019_02_21_153035_alter_customer_id_in_product_reviews_table', 1),
(73, '2019_02_21_153851_add_swatch_value_columns_in_attribute_options_table', 1),
(74, '2019_03_15_123337_add_display_mode_column_in_categories_table', 1),
(75, '2019_03_28_103658_add_notes_column_in_customers_table', 1),
(76, '2019_04_24_155820_alter_product_flat_table', 1),
(77, '2019_05_13_024320_remove_tables', 1),
(78, '2019_05_13_024321_create_cart_rules_table', 1),
(79, '2019_05_13_024322_create_cart_rule_channels_table', 1),
(80, '2019_05_13_024323_create_cart_rule_customer_groups_table', 1),
(81, '2019_05_13_024324_create_cart_rule_translations_table', 1),
(82, '2019_05_13_024325_create_cart_rule_customers_table', 1),
(83, '2019_05_13_024326_create_cart_rule_coupons_table', 1),
(84, '2019_05_13_024327_create_cart_rule_coupon_usage_table', 1),
(85, '2019_05_22_165833_update_zipcode_column_type_to_varchar_in_cart_address_table', 1),
(86, '2019_05_23_113407_add_remaining_column_in_product_flat_table', 1),
(87, '2019_05_23_155520_add_discount_columns_in_invoice_items_table', 1),
(88, '2019_05_23_184029_rename_discount_columns_in_cart_table', 1),
(89, '2019_06_04_114009_add_phone_column_in_customers_table', 1),
(90, '2019_06_06_195905_update_custom_price_to_nullable_in_cart_items', 1),
(91, '2019_06_15_183412_add_code_column_in_customer_groups_table', 1),
(92, '2019_06_17_180258_create_product_downloadable_samples_table', 1),
(93, '2019_06_17_180314_create_product_downloadable_sample_translations_table', 1),
(94, '2019_06_17_180325_create_product_downloadable_links_table', 1),
(95, '2019_06_17_180346_create_product_downloadable_link_translations_table', 1),
(96, '2019_06_19_162817_remove_unique_in_phone_column_in_customers_table', 1),
(97, '2019_06_21_130512_update_weight_column_deafult_value_in_cart_items_table', 1),
(98, '2019_06_21_202249_create_downloadable_link_purchased_table', 1),
(99, '2019_07_02_180307_create_booking_products_table', 1),
(100, '2019_07_05_114157_add_symbol_column_in_currencies_table', 1),
(101, '2019_07_05_154415_create_booking_product_default_slots_table', 1),
(102, '2019_07_05_154429_create_booking_product_appointment_slots_table', 1),
(103, '2019_07_05_154440_create_booking_product_event_tickets_table', 1),
(104, '2019_07_05_154451_create_booking_product_rental_slots_table', 1),
(105, '2019_07_05_154502_create_booking_product_table_slots_table', 1),
(106, '2019_07_11_151210_add_locale_id_in_category_translations', 1),
(107, '2019_07_23_033128_alter_locales_table', 1),
(108, '2019_07_23_174708_create_velocity_contents_table', 1),
(109, '2019_07_23_175212_create_velocity_contents_translations_table', 1),
(110, '2019_07_29_142734_add_use_in_flat_column_in_attributes_table', 1),
(111, '2019_07_30_153530_create_cms_pages_table', 1),
(112, '2019_07_31_143339_create_category_filterable_attributes_table', 1),
(113, '2019_08_02_105320_create_product_grouped_products_table', 1),
(114, '2019_08_12_184925_add_additional_cloumn_in_wishlist_table', 1),
(115, '2019_08_20_170510_create_product_bundle_options_table', 1),
(116, '2019_08_20_170520_create_product_bundle_option_translations_table', 1),
(117, '2019_08_20_170528_create_product_bundle_option_products_table', 1),
(118, '2019_08_21_123707_add_seo_column_in_channels_table', 1),
(119, '2019_09_11_184511_create_refunds_table', 1),
(120, '2019_09_11_184519_create_refund_items_table', 1),
(121, '2019_09_26_163950_remove_channel_id_from_customers_table', 1),
(122, '2019_10_03_105451_change_rate_column_in_currency_exchange_rates_table', 1),
(123, '2019_10_21_105136_order_brands', 1),
(124, '2019_10_24_173358_change_postcode_column_type_in_order_address_table', 1),
(125, '2019_10_24_173437_change_postcode_column_type_in_cart_address_table', 1),
(126, '2019_10_24_173507_change_postcode_column_type_in_customer_addresses_table', 1),
(127, '2019_11_21_194541_add_column_url_path_to_category_translations', 1),
(128, '2019_11_21_194608_add_stored_function_to_get_url_path_of_category', 1),
(129, '2019_11_21_194627_add_trigger_to_category_translations', 1),
(130, '2019_11_21_194648_add_url_path_to_existing_category_translations', 1),
(131, '2019_11_21_194703_add_trigger_to_categories', 1),
(132, '2019_11_25_171136_add_applied_cart_rule_ids_column_in_cart_table', 1),
(133, '2019_11_25_171208_add_applied_cart_rule_ids_column_in_cart_items_table', 1),
(134, '2019_11_30_124437_add_applied_cart_rule_ids_column_in_orders_table', 1),
(135, '2019_11_30_165644_add_discount_columns_in_cart_shipping_rates_table', 1),
(136, '2019_12_03_175253_create_remove_catalog_rule_tables', 1),
(137, '2019_12_03_184613_create_catalog_rules_table', 1),
(138, '2019_12_03_184651_create_catalog_rule_channels_table', 1),
(139, '2019_12_03_184732_create_catalog_rule_customer_groups_table', 1),
(140, '2019_12_06_101110_create_catalog_rule_products_table', 1),
(141, '2019_12_06_110507_create_catalog_rule_product_prices_table', 1),
(142, '2019_12_30_155256_create_velocity_meta_data', 1),
(143, '2020_01_02_201029_add_api_token_columns', 1),
(144, '2020_01_06_173505_alter_trigger_category_translations', 1),
(145, '2020_01_06_173524_alter_stored_function_url_path_category', 1),
(146, '2020_01_06_195305_alter_trigger_on_categories', 1),
(147, '2020_01_09_154851_add_shipping_discount_columns_in_orders_table', 1),
(148, '2020_01_09_202815_add_inventory_source_name_column_in_shipments_table', 1),
(149, '2020_01_10_122226_update_velocity_meta_data', 1),
(150, '2020_01_10_151902_customer_address_improvements', 1),
(151, '2020_01_13_131431_alter_float_value_column_type_in_product_attribute_values_table', 1),
(152, '2020_01_13_155803_add_velocity_locale_icon', 1),
(153, '2020_01_13_192149_add_category_velocity_meta_data', 1),
(154, '2020_01_14_191854_create_cms_page_translations_table', 1),
(155, '2020_01_14_192206_remove_columns_from_cms_pages_table', 1),
(156, '2020_01_15_130209_create_cms_page_channels_table', 1),
(157, '2020_01_15_145637_add_product_policy', 1),
(158, '2020_01_15_152121_add_banner_link', 1),
(159, '2020_01_28_102422_add_new_column_and_rename_name_column_in_customer_addresses_table', 1),
(160, '2020_01_29_124748_alter_name_column_in_country_state_translations_table', 1),
(161, '2020_02_18_165639_create_bookings_table', 1),
(162, '2020_02_21_121201_create_booking_product_event_ticket_translations_table', 1),
(163, '2020_02_24_190025_add_is_comparable_column_in_attributes_table', 1),
(164, '2020_02_25_181902_propagate_company_name', 1),
(165, '2020_02_26_163908_change_column_type_in_cart_rules_table', 1),
(166, '2020_02_28_105104_fix_order_columns', 1),
(167, '2020_02_28_111958_create_customer_compare_products_table', 1),
(168, '2020_03_23_201431_alter_booking_products_table', 1),
(169, '2020_04_13_224524_add_locale_in_sliders_table', 1),
(170, '2020_04_16_130351_remove_channel_from_tax_category', 1),
(171, '2020_04_16_185147_add_table_addresses', 1),
(172, '2019_06_20_145144_create_b2b_marketplace_suppliers_table', 2),
(173, '2019_06_21_145145_create_b2b_marketplace_supplier_addresses_table', 2),
(174, '2019_06_21_145148_create_b2b_supplier_password_resets_table', 2),
(175, '2019_06_21_145148_create_supplier_password_resets_table', 2),
(176, '2019_07_09_121406_create_b2b_marketplace_products_table', 2),
(177, '2019_07_09_133211_create_b2b_marketplace_product_images_table', 2),
(178, '2019_07_11_105029_create_b2b_marketplace_orders_table', 2),
(179, '2019_07_11_105810_create_b2b_marketplace_order_items_table', 2),
(180, '2019_07_12_101932_create_b2b_marketplace_invoices_table', 2),
(181, '2019_07_12_101959_create_b2b_marketplace_invoice_items_table', 2),
(182, '2019_07_12_190632_create_b2b_marketplace_shipments_table', 2),
(183, '2019_07_12_190702_create_b2b_marketplace_shipment_items_table', 2),
(184, '2019_07_15_155635_create_b2b_marketplace_transactions_table', 2),
(185, '2019_07_15_174654_create_b2b_marketplace_supplier_reviews_table', 2),
(186, '2019_07_24_105134_create_b2b_marketplace_customer_quotes_table', 2),
(187, '2019_07_24_105134_create_b2b_marketplace_quote_table', 2),
(188, '2019_07_24_111758_create_b2b_marketplace_customer_quote_items_table', 2),
(189, '2019_07_24_111758_create_b2b_marketplace_quote_produts_table', 2),
(190, '2019_07_29_150110_create_b2b_marketplace_supplier_quote_item_table', 2),
(191, '2019_07_29_150110_create_b2b_marketplace_supplier_quote_items_table', 2),
(192, '2019_07_31_153239_add_is_approve_column_in_b2b_marketplace_quote_products_table', 2),
(193, '2019_08_02_190739_create_b2b_marketplace_quote_messages_table', 2),
(194, '2019_12_29_164515_create_b2b_marketplace_supplier_category_table', 2),
(195, '2019_12_31_131601_add_supplier_column_to_product_inventories_table', 2),
(196, '2020_01_03_190222_create_b2b_marketplace_customer_supplier_messages_table', 2),
(197, '2020_01_03_190222_create_b2b_marketplace_message_mappings_table', 2),
(198, '2020_01_09_205714_add_corporate_supplier_address_to_b2b_marketplace_supplier_addresses_table', 2),
(199, '2020_01_10_175050_create_b2b_marketplace_quote_images_table', 2),
(200, '2020_01_18_155103_add_categories_column_to_b2b_marketplace_customer_quote_items_table', 2),
(201, '2020_01_29_201815_create_b2b_marketplace_messages_table', 2),
(202, '2020_01_30_211101_create_b2b_marketplace_quote_attachments_table', 2),
(203, '2019_02_20_131808_create_b2b_marketplace_stripe_cards_table', 3),
(204, '2019_06_09_152250_create_b2b_marketplace_stripe_suppliers_table', 3),
(205, '2019_06_11_174319_create_b2b_marketplace_stripe_cart_table', 3),
(206, '2019_06_07_122059_customer_documents_table', 4),
(207, '2019_04_23_115227_create_marketplace_bulkupload_dataflowprofile_table', 5),
(208, '2019_04_23_182018_create_marketplace_import_new_products_table', 5),
(209, '2019_04_29_105529_create_marketplace__import_new_products_by_admin_table', 5),
(210, '2019_06_21_102504_marketplace_bulkupload_admin_dataflowprofile', 5);

-- --------------------------------------------------------

--
-- Structure de la table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `increment_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_guest` tinyint(1) DEFAULT NULL,
  `customer_email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_first_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_last_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_company_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `customer_vat_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `coupon_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_gift` tinyint(1) NOT NULL DEFAULT '0',
  `total_item_count` int DEFAULT NULL,
  `total_qty_ordered` int DEFAULT NULL,
  `base_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grand_total` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total` decimal(12,4) DEFAULT '0.0000',
  `grand_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `grand_total_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total_refunded` decimal(12,4) DEFAULT '0.0000',
  `sub_total` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total` decimal(12,4) DEFAULT '0.0000',
  `sub_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total_invoiced` decimal(12,4) DEFAULT '0.0000',
  `sub_total_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total_refunded` decimal(12,4) DEFAULT '0.0000',
  `discount_percent` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `discount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_discount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `discount_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_discount_refunded` decimal(12,4) DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `tax_amount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `tax_amount_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount_refunded` decimal(12,4) DEFAULT '0.0000',
  `shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `shipping_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_invoiced` decimal(12,4) DEFAULT '0.0000',
  `shipping_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_refunded` decimal(12,4) DEFAULT '0.0000',
  `customer_id` int UNSIGNED DEFAULT NULL,
  `customer_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel_id` int UNSIGNED DEFAULT NULL,
  `channel_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `cart_id` int DEFAULT NULL,
  `applied_cart_rule_ids` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_discount_amount` decimal(12,4) DEFAULT '0.0000',
  PRIMARY KEY (`id`),
  KEY `orders_customer_id_foreign` (`customer_id`),
  KEY `orders_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `order_brands`
--

DROP TABLE IF EXISTS `order_brands`;
CREATE TABLE IF NOT EXISTS `order_brands` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` int UNSIGNED DEFAULT NULL,
  `order_item_id` int UNSIGNED DEFAULT NULL,
  `product_id` int UNSIGNED DEFAULT NULL,
  `brand` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_brands_order_id_foreign` (`order_id`),
  KEY `order_brands_order_item_id_foreign` (`order_item_id`),
  KEY `order_brands_product_id_foreign` (`product_id`),
  KEY `order_brands_brand_foreign` (`brand`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `sku` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `coupon_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weight` decimal(12,4) DEFAULT '0.0000',
  `total_weight` decimal(12,4) DEFAULT '0.0000',
  `qty_ordered` int DEFAULT '0',
  `qty_shipped` int DEFAULT '0',
  `qty_invoiced` int DEFAULT '0',
  `qty_canceled` int DEFAULT '0',
  `qty_refunded` int DEFAULT '0',
  `price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `total` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_total` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `total_invoiced` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_total_invoiced` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `amount_refunded` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_amount_refunded` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `discount_percent` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `discount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_discount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `discount_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_discount_refunded` decimal(12,4) DEFAULT '0.0000',
  `tax_percent` decimal(12,4) DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `tax_amount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount_invoiced` decimal(12,4) DEFAULT '0.0000',
  `tax_amount_refunded` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount_refunded` decimal(12,4) DEFAULT '0.0000',
  `product_id` int UNSIGNED DEFAULT NULL,
  `product_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_id` int UNSIGNED DEFAULT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `additional` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_foreign` (`order_id`),
  KEY `order_items_parent_id_foreign` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `order_payment`
--

DROP TABLE IF EXISTS `order_payment`;
CREATE TABLE IF NOT EXISTS `order_payment` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `method` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `method_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_payment_order_id_foreign` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE IF NOT EXISTS `password_resets` (
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `products`
--

DROP TABLE IF EXISTS `products`;
CREATE TABLE IF NOT EXISTS `products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `sku` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `attribute_family_id` int UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_sku_unique` (`sku`),
  KEY `products_attribute_family_id_foreign` (`attribute_family_id`),
  KEY `products_parent_id_foreign` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `products`
--

INSERT INTO `products` (`id`, `sku`, `type`, `created_at`, `updated_at`, `parent_id`, `attribute_family_id`) VALUES
(1, '1234', 'simple', '2020-09-22 07:34:21', '2020-09-22 07:34:21', NULL, 1),
(2, 'jjjj', 'simple', '2020-09-24 08:01:50', '2020-09-24 08:01:50', NULL, 1),
(3, '5566556655', 'simple', '2020-10-07 05:10:09', '2020-10-07 05:10:09', NULL, 1),
(4, '88888888', 'simple', '2020-10-07 05:13:49', '2020-10-07 05:13:49', NULL, 1),
(5, '888888643', 'simple', '2020-10-07 05:26:09', '2020-10-07 05:26:09', NULL, 1),
(6, '233333333', 'simple', '2020-10-07 05:29:42', '2020-10-07 05:29:42', NULL, 1),
(7, '984444444', 'simple', '2020-10-07 09:27:18', '2020-10-07 09:27:18', NULL, 1),
(8, 'sdqdsqdsqqds', 'simple', '2020-10-12 17:08:32', '2020-10-12 17:08:32', NULL, 1);

-- --------------------------------------------------------

--
-- Structure de la table `product_attribute_values`
--

DROP TABLE IF EXISTS `product_attribute_values`;
CREATE TABLE IF NOT EXISTS `product_attribute_values` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `text_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `boolean_value` tinyint(1) DEFAULT NULL,
  `integer_value` int DEFAULT NULL,
  `float_value` decimal(12,4) DEFAULT NULL,
  `datetime_value` datetime DEFAULT NULL,
  `date_value` date DEFAULT NULL,
  `json_value` json DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `attribute_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chanel_locale_attribute_value_index_unique` (`channel`,`locale`,`attribute_id`,`product_id`),
  KEY `product_attribute_values_product_id_foreign` (`product_id`),
  KEY `product_attribute_values_attribute_id_foreign` (`attribute_id`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `product_attribute_values`
--

INSERT INTO `product_attribute_values` (`id`, `locale`, `channel`, `text_value`, `boolean_value`, `integer_value`, `float_value`, `datetime_value`, `date_value`, `json_value`, `product_id`, `attribute_id`) VALUES
(1, 'fr', 'default', '<p>Test de produit</p>', NULL, NULL, NULL, NULL, NULL, NULL, 1, 9),
(2, 'fr', 'default', '<p>test de produit</p>', NULL, NULL, NULL, NULL, NULL, NULL, 1, 10),
(3, NULL, NULL, '1234', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1),
(4, 'fr', 'default', 'Test', NULL, NULL, NULL, NULL, NULL, NULL, 1, 2),
(5, NULL, NULL, 'test', NULL, NULL, NULL, NULL, NULL, NULL, 1, 3),
(6, NULL, 'default', NULL, NULL, 1, NULL, NULL, NULL, NULL, 1, 4),
(7, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 1, 5),
(8, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 1, 6),
(9, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 1, 7),
(10, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 1, 8),
(11, NULL, NULL, NULL, NULL, 5, NULL, NULL, NULL, NULL, 1, 23),
(13, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 1, 26),
(14, 'fr', 'default', '', NULL, NULL, NULL, NULL, NULL, NULL, 1, 16),
(15, 'fr', 'default', '', NULL, NULL, NULL, NULL, NULL, NULL, 1, 17),
(16, 'fr', 'default', '', NULL, NULL, NULL, NULL, NULL, NULL, 1, 18),
(17, NULL, NULL, NULL, NULL, NULL, '150.0000', NULL, NULL, NULL, 1, 11),
(18, NULL, 'default', NULL, NULL, NULL, '100.0000', NULL, NULL, NULL, 1, 12),
(19, NULL, NULL, NULL, NULL, NULL, '0.0000', NULL, NULL, NULL, 1, 13),
(23, NULL, NULL, '150', NULL, NULL, NULL, NULL, NULL, NULL, 1, 22),
(24, NULL, NULL, NULL, NULL, 11, NULL, NULL, NULL, NULL, 1, 27),
(25, NULL, 'default', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 14),
(26, NULL, 'default', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 15),
(28, NULL, NULL, 'Test de libéllé', NULL, NULL, NULL, NULL, NULL, NULL, 1, 29),
(29, NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, NULL, 1, 30),
(30, 'fr', 'winebtob', '<p>dsqdsqd</p>', NULL, NULL, NULL, NULL, NULL, NULL, 1, 9),
(31, 'fr', 'winebtob', '<p>qsdqsd</p>', NULL, NULL, NULL, NULL, NULL, NULL, 1, 10),
(32, 'fr', 'winebtob', 'test', NULL, NULL, NULL, NULL, NULL, NULL, 1, 2),
(33, NULL, 'winebtob', NULL, NULL, 1, NULL, NULL, NULL, NULL, 1, 4),
(34, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 1, 16),
(35, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 1, 17),
(36, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 1, 18),
(37, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 12),
(38, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 14),
(39, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 15),
(40, 'fr', 'winebtob', '<p>Test de description</p>', NULL, NULL, NULL, NULL, NULL, NULL, 3, 9),
(41, 'fr', 'winebtob', '<p>test</p>', NULL, NULL, NULL, NULL, NULL, NULL, 3, 10),
(42, NULL, NULL, '5566556655', NULL, NULL, NULL, NULL, NULL, NULL, 3, 1),
(43, 'fr', 'winebtob', 'Pinot blanc 2019 - 75 cl', NULL, NULL, NULL, NULL, NULL, NULL, 3, 2),
(44, NULL, NULL, 'pinot-blanc-2019---75-cl', NULL, NULL, NULL, NULL, NULL, NULL, 3, 3),
(45, NULL, 'winebtob', NULL, NULL, 1, NULL, NULL, NULL, NULL, 3, 4),
(46, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 3, 5),
(47, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 3, 6),
(48, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 3, 7),
(49, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 3, 8),
(50, NULL, NULL, NULL, NULL, 5, NULL, NULL, NULL, NULL, 3, 23),
(51, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 3, 26),
(52, NULL, NULL, NULL, NULL, 11, NULL, NULL, NULL, NULL, 3, 27),
(53, NULL, NULL, 'Pinot blanc 2019 - 75 cl', NULL, NULL, NULL, NULL, NULL, NULL, 3, 29),
(54, NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, NULL, 3, 30),
(55, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 3, 16),
(56, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 3, 17),
(57, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 3, 18),
(58, NULL, NULL, NULL, NULL, NULL, '9.5000', NULL, NULL, NULL, 3, 11),
(59, NULL, 'winebtob', NULL, NULL, NULL, '8.0000', NULL, NULL, NULL, 3, 12),
(60, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3, 13),
(61, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3, 14),
(62, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3, 15),
(63, NULL, NULL, '150', NULL, NULL, NULL, NULL, NULL, NULL, 3, 22),
(64, 'fr', 'winebtob', '<p>test</p>', NULL, NULL, NULL, NULL, NULL, NULL, 4, 9),
(65, 'fr', 'winebtob', '<p>test</p>', NULL, NULL, NULL, NULL, NULL, NULL, 4, 10),
(66, NULL, NULL, '88888888', NULL, NULL, NULL, NULL, NULL, NULL, 4, 1),
(67, 'fr', 'winebtob', 'les Darons 2017- By Jeff Carrel', NULL, NULL, NULL, NULL, NULL, NULL, 4, 2),
(68, NULL, NULL, 'les-darons-2017--by-jeff-carrel', NULL, NULL, NULL, NULL, NULL, NULL, 4, 3),
(69, NULL, 'winebtob', NULL, NULL, 1, NULL, NULL, NULL, NULL, 4, 4),
(70, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 4, 5),
(71, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 4, 6),
(72, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 4, 7),
(73, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 4, 8),
(74, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 4, 23),
(75, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 4, 26),
(76, NULL, NULL, NULL, NULL, 13, NULL, NULL, NULL, NULL, 4, 27),
(77, NULL, NULL, 'les Darons 2017- By Jeff Carrel', NULL, NULL, NULL, NULL, NULL, NULL, 4, 29),
(78, NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, NULL, 4, 30),
(79, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 4, 16),
(80, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 4, 17),
(81, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 4, 18),
(82, NULL, NULL, NULL, NULL, NULL, '110.0000', NULL, NULL, NULL, 4, 11),
(83, NULL, 'winebtob', NULL, NULL, NULL, '100.0000', NULL, NULL, NULL, 4, 12),
(84, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4, 13),
(85, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4, 14),
(86, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4, 15),
(87, NULL, NULL, '150', NULL, NULL, NULL, NULL, NULL, NULL, 4, 22),
(88, 'fr', 'winebtob', '<p>test</p>', NULL, NULL, NULL, NULL, NULL, NULL, 5, 9),
(89, 'fr', 'winebtob', '<p>test</p>', NULL, NULL, NULL, NULL, NULL, NULL, 5, 10),
(90, NULL, NULL, '888888643', NULL, NULL, NULL, NULL, NULL, NULL, 5, 1),
(91, 'fr', 'winebtob', 'VIN ROUGE MARGAUX CHÂTEAU LASCOMBES 2016', NULL, NULL, NULL, NULL, NULL, NULL, 5, 2),
(92, NULL, NULL, 'vin-rouge-margaux-chateau-lascombes-2016', NULL, NULL, NULL, NULL, NULL, NULL, 5, 3),
(93, NULL, 'winebtob', NULL, NULL, 1, NULL, NULL, NULL, NULL, 5, 4),
(94, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 5, 5),
(95, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 5, 6),
(96, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 5, 7),
(97, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 5, 8),
(98, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 5, 23),
(99, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 5, 26),
(100, NULL, NULL, NULL, NULL, 13, NULL, NULL, NULL, NULL, 5, 27),
(101, NULL, NULL, 'VIN ROUGE MARGAUX CHÂTEAU LASCOMBES 2016', NULL, NULL, NULL, NULL, NULL, NULL, 5, 29),
(102, NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, NULL, 5, 30),
(103, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 5, 16),
(104, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 5, 17),
(105, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 5, 18),
(106, NULL, NULL, NULL, NULL, NULL, '200.0000', NULL, NULL, NULL, 5, 11),
(107, NULL, 'winebtob', NULL, NULL, NULL, '150.0000', NULL, NULL, NULL, 5, 12),
(108, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 13),
(109, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 14),
(110, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 15),
(111, NULL, NULL, '150', NULL, NULL, NULL, NULL, NULL, NULL, 5, 22),
(112, 'fr', 'winebtob', '<p>test</p>', NULL, NULL, NULL, NULL, NULL, NULL, 6, 9),
(113, 'fr', 'winebtob', '<p>test ddd</p>', NULL, NULL, NULL, NULL, NULL, NULL, 6, 10),
(114, NULL, NULL, '233333333', NULL, NULL, NULL, NULL, NULL, NULL, 6, 1),
(115, 'fr', 'winebtob', 'Vin ROUGE Château lagune', NULL, NULL, NULL, NULL, NULL, NULL, 6, 2),
(116, NULL, NULL, 'vin-rouge-chateau-lagune', NULL, NULL, NULL, NULL, NULL, NULL, 6, 3),
(117, NULL, 'winebtob', NULL, NULL, 1, NULL, NULL, NULL, NULL, 6, 4),
(118, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 6, 5),
(119, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 6, 6),
(120, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 6, 7),
(121, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 6, 8),
(122, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 6, 23),
(123, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 6, 26),
(124, NULL, NULL, NULL, NULL, 13, NULL, NULL, NULL, NULL, 6, 27),
(125, NULL, NULL, 'Vin ROUGE Château lagune', NULL, NULL, NULL, NULL, NULL, NULL, 6, 29),
(126, NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, NULL, 6, 30),
(127, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 6, 16),
(128, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 6, 17),
(129, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 6, 18),
(130, NULL, NULL, NULL, NULL, NULL, '54.0000', NULL, NULL, NULL, 6, 11),
(131, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 6, 12),
(132, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 6, 13),
(133, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 6, 14),
(134, NULL, 'winebtob', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 6, 15),
(135, NULL, NULL, '150', NULL, NULL, NULL, NULL, NULL, NULL, 6, 22),
(136, 'fr', 'winebtob', '<p>test courte</p>', NULL, NULL, NULL, NULL, NULL, NULL, 7, 9),
(137, 'fr', 'winebtob', '<p>description longue</p>', NULL, NULL, NULL, NULL, NULL, NULL, 7, 10),
(138, NULL, NULL, '984444444', NULL, NULL, NULL, NULL, NULL, NULL, 7, 1),
(139, 'fr', 'winebtob', 'vin test', NULL, NULL, NULL, NULL, NULL, NULL, 7, 2),
(140, NULL, NULL, 'vin-test', NULL, NULL, NULL, NULL, NULL, NULL, 7, 3),
(141, NULL, 'winebtob', NULL, NULL, 1, NULL, NULL, NULL, NULL, 7, 4),
(142, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 7, 5),
(143, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 7, 6),
(144, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 7, 7),
(145, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 7, 8),
(146, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, 7, 23),
(147, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 7, 26),
(148, NULL, NULL, NULL, NULL, 11, NULL, NULL, NULL, NULL, 7, 27),
(149, NULL, NULL, 'vin test', NULL, NULL, NULL, NULL, NULL, NULL, 7, 29),
(150, NULL, NULL, NULL, NULL, 31, NULL, NULL, NULL, NULL, 7, 30),
(151, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 7, 16),
(152, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 7, 17),
(153, 'fr', 'winebtob', '', NULL, NULL, NULL, NULL, NULL, NULL, 7, 18),
(154, NULL, NULL, NULL, NULL, NULL, '10.5000', NULL, NULL, NULL, 7, 11),
(155, NULL, 'winebtob', NULL, NULL, NULL, '0.0000', NULL, NULL, NULL, 7, 12),
(156, NULL, NULL, NULL, NULL, NULL, '0.0000', NULL, NULL, NULL, 7, 13),
(157, NULL, NULL, '150', NULL, NULL, NULL, NULL, NULL, NULL, 7, 22);

-- --------------------------------------------------------

--
-- Structure de la table `product_bundle_options`
--

DROP TABLE IF EXISTS `product_bundle_options`;
CREATE TABLE IF NOT EXISTS `product_bundle_options` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '1',
  `sort_order` int NOT NULL DEFAULT '0',
  `product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_bundle_options_product_id_foreign` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_bundle_option_products`
--

DROP TABLE IF EXISTS `product_bundle_option_products`;
CREATE TABLE IF NOT EXISTS `product_bundle_option_products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `qty` int NOT NULL DEFAULT '0',
  `is_user_defined` tinyint(1) NOT NULL DEFAULT '1',
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL DEFAULT '0',
  `product_bundle_option_id` int UNSIGNED NOT NULL,
  `product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_bundle_option_products_product_bundle_option_id_foreign` (`product_bundle_option_id`),
  KEY `product_bundle_option_products_product_id_foreign` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_bundle_option_translations`
--

DROP TABLE IF EXISTS `product_bundle_option_translations`;
CREATE TABLE IF NOT EXISTS `product_bundle_option_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `product_bundle_option_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_bundle_option_translations_option_id_locale_unique` (`product_bundle_option_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_categories`
--

DROP TABLE IF EXISTS `product_categories`;
CREATE TABLE IF NOT EXISTS `product_categories` (
  `product_id` int UNSIGNED NOT NULL,
  `category_id` int UNSIGNED NOT NULL,
  KEY `product_categories_product_id_foreign` (`product_id`),
  KEY `product_categories_category_id_foreign` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `product_categories`
--

INSERT INTO `product_categories` (`product_id`, `category_id`) VALUES
(1, 2),
(1, 3),
(3, 2),
(3, 3),
(3, 61),
(4, 2),
(4, 4),
(5, 2),
(5, 4),
(6, 1),
(6, 2),
(6, 4),
(7, 2),
(7, 3),
(7, 61);

-- --------------------------------------------------------

--
-- Structure de la table `product_cross_sells`
--

DROP TABLE IF EXISTS `product_cross_sells`;
CREATE TABLE IF NOT EXISTS `product_cross_sells` (
  `parent_id` int UNSIGNED NOT NULL,
  `child_id` int UNSIGNED NOT NULL,
  KEY `product_cross_sells_parent_id_foreign` (`parent_id`),
  KEY `product_cross_sells_child_id_foreign` (`child_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_downloadable_links`
--

DROP TABLE IF EXISTS `product_downloadable_links`;
CREATE TABLE IF NOT EXISTS `product_downloadable_links` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `url` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `sample_url` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sample_file` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sample_file_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sample_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `downloads` int NOT NULL DEFAULT '0',
  `sort_order` int DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_downloadable_links_product_id_foreign` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_downloadable_link_translations`
--

DROP TABLE IF EXISTS `product_downloadable_link_translations`;
CREATE TABLE IF NOT EXISTS `product_downloadable_link_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `product_downloadable_link_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `link_translations_link_id_foreign` (`product_downloadable_link_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_downloadable_samples`
--

DROP TABLE IF EXISTS `product_downloadable_samples`;
CREATE TABLE IF NOT EXISTS `product_downloadable_samples` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `url` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sort_order` int DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_downloadable_samples_product_id_foreign` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_downloadable_sample_translations`
--

DROP TABLE IF EXISTS `product_downloadable_sample_translations`;
CREATE TABLE IF NOT EXISTS `product_downloadable_sample_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `product_downloadable_sample_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sample_translations_sample_id_foreign` (`product_downloadable_sample_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_flat`
--

DROP TABLE IF EXISTS `product_flat`;
CREATE TABLE IF NOT EXISTS `product_flat` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `sku` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `url_key` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new` tinyint(1) DEFAULT NULL,
  `featured` tinyint(1) DEFAULT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `thumbnail` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(12,4) DEFAULT NULL,
  `cost` decimal(12,4) DEFAULT NULL,
  `special_price` decimal(12,4) DEFAULT NULL,
  `special_price_from` date DEFAULT NULL,
  `special_price_to` date DEFAULT NULL,
  `weight` decimal(12,4) DEFAULT NULL,
  `color` int DEFAULT NULL,
  `color_label` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `visible_individually` tinyint(1) DEFAULT NULL,
  `min_price` decimal(12,4) DEFAULT NULL,
  `max_price` decimal(12,4) DEFAULT NULL,
  `short_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_keywords` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `region` int DEFAULT NULL,
  `region_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Origine` int DEFAULT NULL,
  `Origine_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Pays` int DEFAULT NULL,
  `Pays_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Millesime` int DEFAULT NULL,
  `Millesime_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Contenance` int DEFAULT NULL,
  `Contenance_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `EAN` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Conditionnement` int DEFAULT NULL,
  `Conditionnement_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PCB` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Mise_en_bouteille` int DEFAULT NULL,
  `Mise_en_bouteille_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Recompenses` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Recompenses_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Top_affaire` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Top_affaire_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Gouts_majeur` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Gouts_majeur_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Gouts` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Conservation` int DEFAULT NULL,
  `Conservation_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Degre_alcoole` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Accord_recommandes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Bouchon` int DEFAULT NULL,
  `Bouchon_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `oeil` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Nez` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Bouche` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Temperature_de_service` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Terroir` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Elaboration` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Type_de_culture` int DEFAULT NULL,
  `Type_de_culture_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `elevage` int DEFAULT NULL,
  `elevage_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Type_de_vendeur` int DEFAULT NULL,
  `Type_de_vendeur_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Caracteristiques` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `Caracteristiques_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_flat_unique_index` (`product_id`,`channel`,`locale`),
  KEY `product_flat_parent_id_foreign` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `product_flat`
--

INSERT INTO `product_flat` (`id`, `sku`, `name`, `description`, `url_key`, `new`, `featured`, `status`, `thumbnail`, `price`, `cost`, `special_price`, `special_price_from`, `special_price_to`, `weight`, `color`, `color_label`, `created_at`, `locale`, `channel`, `product_id`, `updated_at`, `parent_id`, `visible_individually`, `min_price`, `max_price`, `short_description`, `meta_title`, `meta_keywords`, `meta_description`, `region`, `region_label`, `Origine`, `Origine_label`, `Pays`, `Pays_label`, `Millesime`, `Millesime_label`, `Contenance`, `Contenance_label`, `EAN`, `Conditionnement`, `Conditionnement_label`, `PCB`, `Mise_en_bouteille`, `Mise_en_bouteille_label`, `Recompenses`, `Recompenses_label`, `Top_affaire`, `Top_affaire_label`, `Gouts_majeur`, `Gouts_majeur_label`, `Gouts`, `Conservation`, `Conservation_label`, `Degre_alcoole`, `Accord_recommandes`, `Bouchon`, `Bouchon_label`, `oeil`, `Nez`, `Bouche`, `Temperature_de_service`, `Terroir`, `Elaboration`, `Type_de_culture`, `Type_de_culture_label`, `elevage`, `elevage_label`, `Type_de_vendeur`, `Type_de_vendeur_label`, `Caracteristiques`, `Caracteristiques_label`) VALUES
(1, '1234', 'Test', '<p>test de produit</p>', 'test', 1, 1, 1, NULL, '150.0000', '100.0000', '0.0000', NULL, NULL, '150.0000', 1, 'Rouge', '2020-09-22 09:34:21', 'fr', 'default', 1, '2020-09-22 09:34:21', NULL, 1, '150.0000', '150.0000', '<p>Test de produit</p>', '', '', '', 11, 'Alsace', 32, 'Aucune', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2020-09-24 10:01:50', 'fr', 'default', 2, '2020-09-24 10:01:50', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, '1234', 'test', '<p>qsdqsd</p>', 'test', 1, 1, 1, NULL, '150.0000', NULL, '0.0000', NULL, NULL, '150.0000', 5, 'Blanc', '2020-09-22 09:34:21', 'fr', 'winebtob', 1, '2020-09-22 09:34:21', NULL, 1, '150.0000', '150.0000', '<p>dsqdsqd</p>', '', '', '', 11, 'Alsace', 31, 'AOP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(4, '5566556655', 'Pinot blanc 2019 - 75 cl', '<p>test</p>', 'pinot-blanc-2019---75-cl', 1, 1, 1, NULL, '9.5000', '8.0000', NULL, NULL, NULL, '150.0000', 5, 'Blanc', '2020-10-07 07:10:09', 'fr', 'winebtob', 3, '2020-10-07 07:10:09', NULL, 1, '9.5000', '9.5000', '<p>Test de description</p>', '', '', '', 11, 'Alsace', 31, 'AOP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, '88888888', 'les Darons 2017- By Jeff Carrel', '<p>test</p>', 'les-darons-2017--by-jeff-carrel', 1, 1, 1, NULL, '110.0000', '100.0000', NULL, NULL, NULL, '150.0000', 1, 'Rouge', '2020-10-07 07:13:49', 'fr', 'winebtob', 4, '2020-10-07 07:13:49', NULL, 1, '110.0000', '110.0000', '<p>test</p>', '', '', '', 13, 'Bordeaux', 31, 'AOP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, '888888643', 'VIN ROUGE MARGAUX CHÂTEAU LASCOMBES 2016', '<p>test</p>', 'vin-rouge-margaux-chateau-lascombes-2016', 1, 1, 1, NULL, '200.0000', '150.0000', NULL, NULL, NULL, '150.0000', 1, 'Rouge', '2020-10-07 07:26:09', 'fr', 'winebtob', 5, '2020-10-07 07:26:09', NULL, 1, '200.0000', '200.0000', '<p>test</p>', '', '', '', 13, 'Bordeaux', 31, 'AOP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(7, '233333333', 'Vin ROUGE Château lagune', '<p>test ddd</p>', 'vin-rouge-chateau-lagune', 1, 1, 1, NULL, '54.0000', NULL, NULL, NULL, NULL, '150.0000', 1, 'Rouge', '2020-10-07 07:29:42', 'fr', 'winebtob', 6, '2020-10-07 07:29:42', NULL, 1, '54.0000', '54.0000', '<p>test</p>', '', '', '', 13, 'Bordeaux', 31, 'AOP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(8, '984444444', 'vin test', '<p>description longue</p>', 'vin-test', 1, 1, 1, NULL, '10.5000', '0.0000', '0.0000', NULL, NULL, '150.0000', 1, 'Rouge', '2020-10-07 11:27:18', 'fr', 'winebtob', 7, '2020-10-07 11:27:18', NULL, 1, NULL, NULL, '<p>test courte</p>', '', '', '', 11, 'Alsace', 31, 'AOP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(9, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2020-10-12 19:08:32', 'fr', 'winebtob', 8, '2020-10-12 19:08:32', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `product_grouped_products`
--

DROP TABLE IF EXISTS `product_grouped_products`;
CREATE TABLE IF NOT EXISTS `product_grouped_products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `qty` int NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL DEFAULT '0',
  `product_id` int UNSIGNED NOT NULL,
  `associated_product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_grouped_products_product_id_foreign` (`product_id`),
  KEY `product_grouped_products_associated_product_id_foreign` (`associated_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_images`
--

DROP TABLE IF EXISTS `product_images`;
CREATE TABLE IF NOT EXISTS `product_images` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `path` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `product_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_images_product_id_foreign` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `product_images`
--

INSERT INTO `product_images` (`id`, `type`, `path`, `product_id`) VALUES
(1, NULL, 'product/1/Y3G92LiJdTFVFZmzA4Xt0DkPi6cQ21jTqs7vIezR.png', 1),
(2, NULL, 'product/3/jc6tXEQNacKQEEC7j8dR8J1RxcHbba1QmVudTaBi.jpeg', 3),
(3, NULL, 'product/4/rxIy6rgz1AUQvdzXAA9VAYEVx3D6qdx0hLtmiyif.png', 4),
(4, NULL, 'product/5/mO7hJQ9D5v7iy1khq7WefYQEuN7cUw6Oh0DIzZg9.png', 5),
(5, NULL, 'product/6/UrSYJJLvDC0mRHqbWHBdJyJ8KElJLfeUWuz7Z2du.png', 6);

-- --------------------------------------------------------

--
-- Structure de la table `product_inventories`
--

DROP TABLE IF EXISTS `product_inventories`;
CREATE TABLE IF NOT EXISTS `product_inventories` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `qty` int NOT NULL DEFAULT '0',
  `product_id` int UNSIGNED NOT NULL,
  `inventory_source_id` int UNSIGNED NOT NULL,
  `vendor_id` int NOT NULL DEFAULT '0',
  `supplier` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_source_vendor_index_unique` (`product_id`,`inventory_source_id`,`vendor_id`),
  KEY `product_inventories_inventory_source_id_foreign` (`inventory_source_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `product_inventories`
--

INSERT INTO `product_inventories` (`id`, `qty`, `product_id`, `inventory_source_id`, `vendor_id`, `supplier`) VALUES
(1, 100, 1, 1, 0, 2),
(2, 500, 3, 1, 0, NULL),
(3, 10000, 4, 1, 0, NULL),
(4, 500, 5, 1, 0, NULL),
(5, 6000, 6, 1, 0, NULL),
(6, 10, 7, 1, 0, 2);

-- --------------------------------------------------------

--
-- Structure de la table `product_ordered_inventories`
--

DROP TABLE IF EXISTS `product_ordered_inventories`;
CREATE TABLE IF NOT EXISTS `product_ordered_inventories` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `qty` int NOT NULL DEFAULT '0',
  `product_id` int UNSIGNED NOT NULL,
  `channel_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `product_ordered_inventories_product_id_channel_id_unique` (`product_id`,`channel_id`),
  KEY `product_ordered_inventories_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_relations`
--

DROP TABLE IF EXISTS `product_relations`;
CREATE TABLE IF NOT EXISTS `product_relations` (
  `parent_id` int UNSIGNED NOT NULL,
  `child_id` int UNSIGNED NOT NULL,
  KEY `product_relations_parent_id_foreign` (`parent_id`),
  KEY `product_relations_child_id_foreign` (`child_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_reviews`
--

DROP TABLE IF EXISTS `product_reviews`;
CREATE TABLE IF NOT EXISTS `product_reviews` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rating` int NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `customer_id` int DEFAULT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `product_reviews_product_id_foreign` (`product_id`),
  KEY `product_reviews_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `product_reviews`
--

INSERT INTO `product_reviews` (`id`, `title`, `rating`, `comment`, `status`, `created_at`, `updated_at`, `product_id`, `customer_id`, `name`) VALUES
(1, 'good', 4, 'test commentaires', 'approved', '2020-09-24 12:59:29', '2020-09-24 13:18:38', 1, 1, 'calixte marchand');

-- --------------------------------------------------------

--
-- Structure de la table `product_super_attributes`
--

DROP TABLE IF EXISTS `product_super_attributes`;
CREATE TABLE IF NOT EXISTS `product_super_attributes` (
  `product_id` int UNSIGNED NOT NULL,
  `attribute_id` int UNSIGNED NOT NULL,
  KEY `product_super_attributes_product_id_foreign` (`product_id`),
  KEY `product_super_attributes_attribute_id_foreign` (`attribute_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `product_up_sells`
--

DROP TABLE IF EXISTS `product_up_sells`;
CREATE TABLE IF NOT EXISTS `product_up_sells` (
  `parent_id` int UNSIGNED NOT NULL,
  `child_id` int UNSIGNED NOT NULL,
  KEY `product_up_sells_parent_id_foreign` (`parent_id`),
  KEY `product_up_sells_child_id_foreign` (`child_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `refunds`
--

DROP TABLE IF EXISTS `refunds`;
CREATE TABLE IF NOT EXISTS `refunds` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `increment_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_sent` tinyint(1) NOT NULL DEFAULT '0',
  `total_qty` int DEFAULT NULL,
  `base_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_currency_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `adjustment_refund` decimal(12,4) DEFAULT '0.0000',
  `base_adjustment_refund` decimal(12,4) DEFAULT '0.0000',
  `adjustment_fee` decimal(12,4) DEFAULT '0.0000',
  `base_adjustment_fee` decimal(12,4) DEFAULT '0.0000',
  `sub_total` decimal(12,4) DEFAULT '0.0000',
  `base_sub_total` decimal(12,4) DEFAULT '0.0000',
  `grand_total` decimal(12,4) DEFAULT '0.0000',
  `base_grand_total` decimal(12,4) DEFAULT '0.0000',
  `shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `base_shipping_amount` decimal(12,4) DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `discount_percent` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `order_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `refunds_order_id_foreign` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `refund_items`
--

DROP TABLE IF EXISTS `refund_items`;
CREATE TABLE IF NOT EXISTS `refund_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sku` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qty` int DEFAULT NULL,
  `price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_price` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `total` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `base_total` decimal(12,4) NOT NULL DEFAULT '0.0000',
  `tax_amount` decimal(12,4) DEFAULT '0.0000',
  `base_tax_amount` decimal(12,4) DEFAULT '0.0000',
  `discount_percent` decimal(12,4) DEFAULT '0.0000',
  `discount_amount` decimal(12,4) DEFAULT '0.0000',
  `base_discount_amount` decimal(12,4) DEFAULT '0.0000',
  `product_id` int UNSIGNED DEFAULT NULL,
  `product_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_item_id` int UNSIGNED DEFAULT NULL,
  `refund_id` int UNSIGNED DEFAULT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `additional` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `refund_items_order_item_id_foreign` (`order_item_id`),
  KEY `refund_items_refund_id_foreign` (`refund_id`),
  KEY `refund_items_parent_id_foreign` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `permission_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissions` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `roles`
--

INSERT INTO `roles` (`id`, `name`, `description`, `permission_type`, `permissions`, `created_at`, `updated_at`) VALUES
(1, 'Administrator', 'Administrator rolem', 'all', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `shipments`
--

DROP TABLE IF EXISTS `shipments`;
CREATE TABLE IF NOT EXISTS `shipments` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `status` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_qty` int DEFAULT NULL,
  `total_weight` int DEFAULT NULL,
  `carrier_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `carrier_title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `track_number` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `email_sent` tinyint(1) NOT NULL DEFAULT '0',
  `customer_id` int UNSIGNED DEFAULT NULL,
  `customer_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_id` int UNSIGNED NOT NULL,
  `order_address_id` int UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `inventory_source_id` int UNSIGNED DEFAULT NULL,
  `inventory_source_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shipments_order_id_foreign` (`order_id`),
  KEY `shipments_inventory_source_id_foreign` (`inventory_source_id`),
  KEY `shipments_order_address_id_foreign` (`order_address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `shipment_items`
--

DROP TABLE IF EXISTS `shipment_items`;
CREATE TABLE IF NOT EXISTS `shipment_items` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sku` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qty` int DEFAULT NULL,
  `weight` int DEFAULT NULL,
  `price` decimal(12,4) DEFAULT '0.0000',
  `base_price` decimal(12,4) DEFAULT '0.0000',
  `total` decimal(12,4) DEFAULT '0.0000',
  `base_total` decimal(12,4) DEFAULT '0.0000',
  `product_id` int UNSIGNED DEFAULT NULL,
  `product_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_item_id` int UNSIGNED DEFAULT NULL,
  `shipment_id` int UNSIGNED NOT NULL,
  `additional` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `shipment_items_shipment_id_foreign` (`shipment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `sliders`
--

DROP TABLE IF EXISTS `sliders`;
CREATE TABLE IF NOT EXISTS `sliders` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `path` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `channel_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `slider_path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sliders_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `subscribers_list`
--

DROP TABLE IF EXISTS `subscribers_list`;
CREATE TABLE IF NOT EXISTS `subscribers_list` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_subscribed` tinyint(1) NOT NULL DEFAULT '0',
  `token` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscribers_list_channel_id_foreign` (`channel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `supplier_password_resets`
--

DROP TABLE IF EXISTS `supplier_password_resets`;
CREATE TABLE IF NOT EXISTS `supplier_password_resets` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  KEY `supplier_password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `tax_categories`
--

DROP TABLE IF EXISTS `tax_categories`;
CREATE TABLE IF NOT EXISTS `tax_categories` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tax_categories_code_unique` (`code`),
  UNIQUE KEY `tax_categories_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `tax_categories`
--

INSERT INTO `tax_categories` (`id`, `code`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'TVA FRANCE 20', 'TVA FRANCE 20', 'TVA FRANCE 20', '2020-09-22 07:37:33', '2020-09-22 07:37:33');

-- --------------------------------------------------------

--
-- Structure de la table `tax_categories_tax_rates`
--

DROP TABLE IF EXISTS `tax_categories_tax_rates`;
CREATE TABLE IF NOT EXISTS `tax_categories_tax_rates` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `tax_category_id` int UNSIGNED NOT NULL,
  `tax_rate_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tax_map_index_unique` (`tax_category_id`,`tax_rate_id`),
  KEY `tax_categories_tax_rates_tax_rate_id_foreign` (`tax_rate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `tax_categories_tax_rates`
--

INSERT INTO `tax_categories_tax_rates` (`id`, `tax_category_id`, `tax_rate_id`, `created_at`, `updated_at`) VALUES
(1, 1, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `tax_rates`
--

DROP TABLE IF EXISTS `tax_rates`;
CREATE TABLE IF NOT EXISTS `tax_rates` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `identifier` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_zip` tinyint(1) NOT NULL DEFAULT '0',
  `zip_code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `zip_from` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `zip_to` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tax_rate` decimal(12,4) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tax_rates_identifier_unique` (`identifier`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `tax_rates`
--

INSERT INTO `tax_rates` (`id`, `identifier`, `is_zip`, `zip_code`, `zip_from`, `zip_to`, `state`, `country`, `tax_rate`, `created_at`, `updated_at`) VALUES
(1, '20%', 0, '75000', NULL, NULL, '', 'FR', '20.0000', '2020-09-22 07:36:25', '2020-09-22 07:36:25'),
(2, '10%', 0, '75000', NULL, NULL, '', 'FR', '10.0000', '2020-09-22 07:36:54', '2020-09-22 07:36:54');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `velocity_contents`
--

DROP TABLE IF EXISTS `velocity_contents`;
CREATE TABLE IF NOT EXISTS `velocity_contents` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `content_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` int UNSIGNED DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `velocity_contents_translations`
--

DROP TABLE IF EXISTS `velocity_contents_translations`;
CREATE TABLE IF NOT EXISTS `velocity_contents_translations` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `content_id` int UNSIGNED DEFAULT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `custom_heading` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page_link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `link_target` tinyint(1) NOT NULL DEFAULT '0',
  `catalog_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `products` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `locale` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `velocity_contents_translations_content_id_foreign` (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `velocity_customer_compare_products`
--

DROP TABLE IF EXISTS `velocity_customer_compare_products`;
CREATE TABLE IF NOT EXISTS `velocity_customer_compare_products` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_flat_id` int UNSIGNED NOT NULL,
  `customer_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `velocity_customer_compare_products_product_flat_id_foreign` (`product_flat_id`),
  KEY `velocity_customer_compare_products_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `velocity_customer_compare_products`
--

INSERT INTO `velocity_customer_compare_products` (`id`, `product_flat_id`, `customer_id`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2020-09-22 20:38:54', '2020-09-22 20:38:54'),
(2, 3, 1, '2020-10-07 05:48:30', '2020-10-07 05:48:30'),
(3, 4, 1, '2020-10-07 05:48:37', '2020-10-07 05:48:37'),
(4, 5, 1, '2020-10-07 05:48:40', '2020-10-07 05:48:40'),
(5, 6, 1, '2020-10-07 05:48:44', '2020-10-07 05:48:44');

-- --------------------------------------------------------

--
-- Structure de la table `velocity_meta_data`
--

DROP TABLE IF EXISTS `velocity_meta_data`;
CREATE TABLE IF NOT EXISTS `velocity_meta_data` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `home_page_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `footer_left_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `footer_middle_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slider` tinyint(1) NOT NULL DEFAULT '0',
  `advertisement` json DEFAULT NULL,
  `sidebar_category_count` int NOT NULL DEFAULT '9',
  `featured_product_count` int NOT NULL DEFAULT '10',
  `new_products_count` int NOT NULL DEFAULT '10',
  `subscription_bar_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `product_view_images` json DEFAULT NULL,
  `product_policy` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `velocity_meta_data`
--

INSERT INTO `velocity_meta_data` (`id`, `home_page_content`, `footer_left_content`, `footer_middle_content`, `slider`, `advertisement`, `sidebar_category_count`, `featured_product_count`, `new_products_count`, `subscription_bar_content`, `created_at`, `updated_at`, `product_view_images`, `product_policy`) VALUES
(1, '<p>@include(\'shop::home.advertisements.advertisement-four\')@include(\'shop::home.featured-products\') @include(\'shop::home.product-policy\') @include(\'shop::home.advertisements.advertisement-three\') @include(\'shop::home.new-products\') @include(\'shop::home.advertisements.advertisement-two\')</p>', '<p>La plate-forme de vente de vins & spiritueux réservée aux professionnels.</p>', '<div class=\"col-lg-6 col-md-12 col-sm-12 no-padding\"><ul type=\"none\"><li><a href=\"https://winebtob.com/about-us/company-profile/\">About Us</a></li><li><a href=\"https://winebtob.com/about-us/company-profile/\">Customer Service</a></li><li><a href=\"https://winebtob.com/about-us/company-profile/\">What&rsquo;s New</a></li><li><a href=\"https://winebtob.com/about-us/company-profile/\">Contact Us </a></li></ul></div><div class=\"col-lg-6 col-md-12 col-sm-12 no-padding\"><ul type=\"none\"><li><a href=\"https://winebtob.com/about-us/company-profile/\"> Order and Returns </a></li><li><a href=\"https://winebtob.com/about-us/company-profile/\"> Payment Policy </a></li><li><a href=\"https://winebtob.com/about-us/company-profile/\"> Shipping Policy</a></li><li><a href=\"https://winebtob.com/about-us/company-profile/\"> Privacy and Cookies Policy </a></li></ul></div>', 1, NULL, 9, 10, 10, '<div class=\"social-icons col-lg-6\"><a href=\"https://winebtob.com\" target=\"_blank\" class=\"unset\" rel=\"noopener noreferrer\"><i class=\"fs24 within-circle rango-facebook\" title=\"facebook\"></i> </a> <a href=\"https://winebtob.com\" target=\"_blank\" class=\"unset\" rel=\"noopener noreferrer\"><i class=\"fs24 within-circle rango-twitter\" title=\"twitter\"></i> </a> <a href=\"https://winebtob.com\" target=\"_blank\" class=\"unset\" rel=\"noopener noreferrer\"><i class=\"fs24 within-circle rango-linked-in\" title=\"linkedin\"></i> </a> <a href=\"https://winebtob.com\" target=\"_blank\" class=\"unset\" rel=\"noopener noreferrer\"><i class=\"fs24 within-circle rango-pintrest\" title=\"Pinterest\"></i> </a> <a href=\"https://winebtob.com\" target=\"_blank\" class=\"unset\" rel=\"noopener noreferrer\"><i class=\"fs24 within-circle rango-youtube\" title=\"Youtube\"></i> </a> <a href=\"https://winebtob.com\" target=\"_blank\" class=\"unset\" rel=\"noopener noreferrer\"><i class=\"fs24 within-circle rango-instagram\" title=\"instagram\"></i></a></div>', NULL, NULL, NULL, '<div class=\"row col-12 remove-padding-margin\"><div class=\"col-lg-4 col-sm-12 product-policy-wrapper\"><div class=\"card\"><div class=\"policy\"><div class=\"left\"><i class=\"rango-van-ship fs40\"></i></div> <div class=\"right\"><span class=\"font-setting fs20\">Free Shipping on Order $20 or More</span></div></div></div></div> <div class=\"col-lg-4 col-sm-12 product-policy-wrapper\"><div class=\"card\"><div class=\"policy\"><div class=\"left\"><i class=\"rango-exchnage fs40\"></i></div> <div class=\"right\"><span class=\"font-setting fs20\">Product Replace &amp; Return Available </span></div></div></div></div> <div class=\"col-lg-4 col-sm-12 product-policy-wrapper\"><div class=\"card\"><div class=\"policy\"><div class=\"left\"><i class=\"rango-exchnage fs40\"></i></div> <div class=\"right\"><span class=\"font-setting fs20\">Product Exchange and EMI Available </span></div></div></div></div></div>');

-- --------------------------------------------------------

--
-- Structure de la table `wishlist`
--

DROP TABLE IF EXISTS `wishlist`;
CREATE TABLE IF NOT EXISTS `wishlist` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `channel_id` int UNSIGNED NOT NULL,
  `product_id` int UNSIGNED NOT NULL,
  `customer_id` int UNSIGNED NOT NULL,
  `item_options` json DEFAULT NULL,
  `moved_to_cart` date DEFAULT NULL,
  `shared` tinyint(1) DEFAULT NULL,
  `time_of_moving` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `additional` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `wishlist_channel_id_foreign` (`channel_id`),
  KEY `wishlist_product_id_foreign` (`product_id`),
  KEY `wishlist_customer_id_foreign` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

--
-- Déchargement des données de la table `wishlist`
--

INSERT INTO `wishlist` (`id`, `channel_id`, `product_id`, `customer_id`, `item_options`, `moved_to_cart`, `shared`, `time_of_moving`, `created_at`, `updated_at`, `additional`) VALUES
(2, 1, 1, 1, NULL, NULL, NULL, NULL, '2020-10-07 05:48:33', '2020-10-07 05:48:33', NULL),
(3, 1, 3, 1, NULL, NULL, NULL, NULL, '2020-10-07 05:48:35', '2020-10-07 05:48:35', NULL),
(4, 1, 4, 1, NULL, NULL, NULL, NULL, '2020-10-07 05:48:38', '2020-10-07 05:48:38', NULL),
(5, 1, 5, 1, NULL, NULL, NULL, NULL, '2020-10-07 05:48:42', '2020-10-07 05:48:42', NULL);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `addresses_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `addresses_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `attribute_groups`
--
ALTER TABLE `attribute_groups`
  ADD CONSTRAINT `attribute_groups_attribute_family_id_foreign` FOREIGN KEY (`attribute_family_id`) REFERENCES `attribute_families` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `attribute_group_mappings`
--
ALTER TABLE `attribute_group_mappings`
  ADD CONSTRAINT `attribute_group_mappings_attribute_group_id_foreign` FOREIGN KEY (`attribute_group_id`) REFERENCES `attribute_groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attribute_group_mappings_attribute_id_foreign` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `attribute_options`
--
ALTER TABLE `attribute_options`
  ADD CONSTRAINT `attribute_options_attribute_id_foreign` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `attribute_option_translations`
--
ALTER TABLE `attribute_option_translations`
  ADD CONSTRAINT `attribute_option_translations_attribute_option_id_foreign` FOREIGN KEY (`attribute_option_id`) REFERENCES `attribute_options` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `attribute_translations`
--
ALTER TABLE `attribute_translations`
  ADD CONSTRAINT `attribute_translations_attribute_id_foreign` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_customer_quotes`
--
ALTER TABLE `b2b_marketplace_customer_quotes`
  ADD CONSTRAINT `b2b_marketplace_customer_quotes_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_customer_quote_items`
--
ALTER TABLE `b2b_marketplace_customer_quote_items`
  ADD CONSTRAINT `b2b_marketplace_customer_quote_items_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_customer_quote_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_customer_quote_items_quote_id_foreign` FOREIGN KEY (`quote_id`) REFERENCES `b2b_marketplace_customer_quotes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_customer_quote_items_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_invoices`
--
ALTER TABLE `b2b_marketplace_invoices`
  ADD CONSTRAINT `b2b_marketplace_invoices_b2b_marketplace_order_id_foreign` FOREIGN KEY (`b2b_marketplace_order_id`) REFERENCES `b2b_marketplace_orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_invoices_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_invoice_items`
--
ALTER TABLE `b2b_marketplace_invoice_items`
  ADD CONSTRAINT `b2b_marketplace_invoice_items_b2b_marketplace_invoice_id_foreign` FOREIGN KEY (`b2b_marketplace_invoice_id`) REFERENCES `b2b_marketplace_invoices` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_invoice_items_invoice_item_id_foreign` FOREIGN KEY (`invoice_item_id`) REFERENCES `invoice_items` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_messages`
--
ALTER TABLE `b2b_marketplace_messages`
  ADD CONSTRAINT `b2b_marketplace_messages_message_id_foreign` FOREIGN KEY (`message_id`) REFERENCES `b2b_marketplace_message_mappings` (`id`);

--
-- Contraintes pour la table `b2b_marketplace_message_mappings`
--
ALTER TABLE `b2b_marketplace_message_mappings`
  ADD CONSTRAINT `b2b_marketplace_message_mappings_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  ADD CONSTRAINT `b2b_marketplace_message_mappings_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`);

--
-- Contraintes pour la table `b2b_marketplace_orders`
--
ALTER TABLE `b2b_marketplace_orders`
  ADD CONSTRAINT `b2b_marketplace_orders_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_orders_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_order_items`
--
ALTER TABLE `b2b_marketplace_order_items`
  ADD CONSTRAINT `b2b_marketplace_order_items_b2b_marketplace_order_id_foreign` FOREIGN KEY (`b2b_marketplace_order_id`) REFERENCES `b2b_marketplace_orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_order_items_b2b_marketplace_product_id_foreign` FOREIGN KEY (`b2b_marketplace_product_id`) REFERENCES `b2b_marketplace_products` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `b2b_marketplace_order_items_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_order_items_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `b2b_marketplace_order_items` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_products`
--
ALTER TABLE `b2b_marketplace_products`
  ADD CONSTRAINT `b2b_marketplace_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_mp_suppliers_products_unique_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_product_images`
--
ALTER TABLE `b2b_marketplace_product_images`
  ADD CONSTRAINT `b2b_mp_products_images_foreign` FOREIGN KEY (`b2b_marketplace_product_id`) REFERENCES `b2b_marketplace_products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_quote`
--
ALTER TABLE `b2b_marketplace_quote`
  ADD CONSTRAINT `b2b_marketplace_quote_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_quote_attachments`
--
ALTER TABLE `b2b_marketplace_quote_attachments`
  ADD CONSTRAINT `b2b_marketplace_quote_attachments_customer_quote_id_foreign` FOREIGN KEY (`customer_quote_id`) REFERENCES `b2b_marketplace_customer_quotes` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_quote_images`
--
ALTER TABLE `b2b_marketplace_quote_images`
  ADD CONSTRAINT `b2b_marketplace_quote_images_customer_quote_id_foreign` FOREIGN KEY (`customer_quote_id`) REFERENCES `b2b_marketplace_customer_quotes` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_quote_messages`
--
ALTER TABLE `b2b_marketplace_quote_messages`
  ADD CONSTRAINT `b2b_marketplace_quote_messages_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_quote_messages_customer_quote_item_id_foreign` FOREIGN KEY (`customer_quote_item_id`) REFERENCES `b2b_marketplace_customer_quote_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_quote_messages_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_quote_messages_supplier_quote_item_id_foreign` FOREIGN KEY (`supplier_quote_item_id`) REFERENCES `b2b_marketplace_supplier_quote_items` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_quote_products`
--
ALTER TABLE `b2b_marketplace_quote_products`
  ADD CONSTRAINT `b2b_marketplace_quote_products_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_quote_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_quote_products_quote_id_foreign` FOREIGN KEY (`quote_id`) REFERENCES `b2b_marketplace_quote` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_quote_products_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_shipments`
--
ALTER TABLE `b2b_marketplace_shipments`
  ADD CONSTRAINT `b2b_marketplace_shipments_b2b_marketplace_order_id_foreign` FOREIGN KEY (`b2b_marketplace_order_id`) REFERENCES `b2b_marketplace_orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_shipments_shipment_id_foreign` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_shipment_items`
--
ALTER TABLE `b2b_marketplace_shipment_items`
  ADD CONSTRAINT `b2b_marketplace_shipment_items_b2b_shipment_item_id_foreign` FOREIGN KEY (`b2b_shipment_item_id`) REFERENCES `shipment_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_mp_shipment_items_id` FOREIGN KEY (`b2b_marketplace_shipment_id`) REFERENCES `b2b_marketplace_shipments` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_stripe_cards`
--
ALTER TABLE `b2b_marketplace_stripe_cards`
  ADD CONSTRAINT `b2b_marketplace_stripe_cards_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_stripe_cart`
--
ALTER TABLE `b2b_marketplace_stripe_cart`
  ADD CONSTRAINT `b2b_marketplace_stripe_cart_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_stripe_suppliers`
--
ALTER TABLE `b2b_marketplace_stripe_suppliers`
  ADD CONSTRAINT `b2b_marketplace_stripe_suppliers_marketplace_seller_id_foreign` FOREIGN KEY (`marketplace_seller_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_suppliers`
--
ALTER TABLE `b2b_marketplace_suppliers`
  ADD CONSTRAINT `b2b_marketplace_suppliers_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`);

--
-- Contraintes pour la table `b2b_marketplace_supplier_addresses`
--
ALTER TABLE `b2b_marketplace_supplier_addresses`
  ADD CONSTRAINT `b2b_marketplace_supplier_addresses_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_supplier_categories`
--
ALTER TABLE `b2b_marketplace_supplier_categories`
  ADD CONSTRAINT `b2b_marketplace_supplier_categories_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_supplier_categories_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_supplier_quote_item`
--
ALTER TABLE `b2b_marketplace_supplier_quote_item`
  ADD CONSTRAINT `b2b_marketplace_supplier_quote_item_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_supplier_quote_item_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_supplier_quote_item_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_supplier_quote_items`
--
ALTER TABLE `b2b_marketplace_supplier_quote_items`
  ADD CONSTRAINT `b2b_marketplace_supplier_quote_items_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_supplier_quote_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_supplier_quote_items_quote_id_foreign` FOREIGN KEY (`quote_id`) REFERENCES `b2b_marketplace_customer_quotes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_supplier_quote_items_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_supplier_reviews`
--
ALTER TABLE `b2b_marketplace_supplier_reviews`
  ADD CONSTRAINT `b2b_marketplace_supplier_reviews_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_mp_reviews_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `b2b_marketplace_transactions`
--
ALTER TABLE `b2b_marketplace_transactions`
  ADD CONSTRAINT `b2b_marketplace_transactions_b2b_marketplace_order_id_foreign` FOREIGN KEY (`b2b_marketplace_order_id`) REFERENCES `b2b_marketplace_orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `b2b_marketplace_transactions_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `b2b_marketplace_suppliers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `booking_products`
--
ALTER TABLE `booking_products`
  ADD CONSTRAINT `booking_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `booking_product_appointment_slots`
--
ALTER TABLE `booking_product_appointment_slots`
  ADD CONSTRAINT `booking_product_appointment_slots_booking_product_id_foreign` FOREIGN KEY (`booking_product_id`) REFERENCES `booking_products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `booking_product_default_slots`
--
ALTER TABLE `booking_product_default_slots`
  ADD CONSTRAINT `booking_product_default_slots_booking_product_id_foreign` FOREIGN KEY (`booking_product_id`) REFERENCES `booking_products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `booking_product_event_tickets`
--
ALTER TABLE `booking_product_event_tickets`
  ADD CONSTRAINT `booking_product_event_tickets_booking_product_id_foreign` FOREIGN KEY (`booking_product_id`) REFERENCES `booking_products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `booking_product_event_ticket_translations`
--
ALTER TABLE `booking_product_event_ticket_translations`
  ADD CONSTRAINT `booking_product_event_ticket_translations_locale_foreign` FOREIGN KEY (`booking_product_event_ticket_id`) REFERENCES `booking_product_event_tickets` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `booking_product_rental_slots`
--
ALTER TABLE `booking_product_rental_slots`
  ADD CONSTRAINT `booking_product_rental_slots_booking_product_id_foreign` FOREIGN KEY (`booking_product_id`) REFERENCES `booking_products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `booking_product_table_slots`
--
ALTER TABLE `booking_product_table_slots`
  ADD CONSTRAINT `booking_product_table_slots_booking_product_id_foreign` FOREIGN KEY (`booking_product_id`) REFERENCES `booking_products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `cart_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_items_tax_category_id_foreign` FOREIGN KEY (`tax_category_id`) REFERENCES `tax_categories` (`id`);

--
-- Contraintes pour la table `cart_payment`
--
ALTER TABLE `cart_payment`
  ADD CONSTRAINT `cart_payment_cart_id_foreign` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart_rule_channels`
--
ALTER TABLE `cart_rule_channels`
  ADD CONSTRAINT `cart_rule_channels_cart_rule_id_foreign` FOREIGN KEY (`cart_rule_id`) REFERENCES `cart_rules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_rule_channels_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart_rule_coupons`
--
ALTER TABLE `cart_rule_coupons`
  ADD CONSTRAINT `cart_rule_coupons_cart_rule_id_foreign` FOREIGN KEY (`cart_rule_id`) REFERENCES `cart_rules` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart_rule_coupon_usage`
--
ALTER TABLE `cart_rule_coupon_usage`
  ADD CONSTRAINT `cart_rule_coupon_usage_cart_rule_coupon_id_foreign` FOREIGN KEY (`cart_rule_coupon_id`) REFERENCES `cart_rule_coupons` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_rule_coupon_usage_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart_rule_customers`
--
ALTER TABLE `cart_rule_customers`
  ADD CONSTRAINT `cart_rule_customers_cart_rule_id_foreign` FOREIGN KEY (`cart_rule_id`) REFERENCES `cart_rules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_rule_customers_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart_rule_customer_groups`
--
ALTER TABLE `cart_rule_customer_groups`
  ADD CONSTRAINT `cart_rule_customer_groups_cart_rule_id_foreign` FOREIGN KEY (`cart_rule_id`) REFERENCES `cart_rules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_rule_customer_groups_customer_group_id_foreign` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_groups` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart_rule_translations`
--
ALTER TABLE `cart_rule_translations`
  ADD CONSTRAINT `cart_rule_translations_cart_rule_id_foreign` FOREIGN KEY (`cart_rule_id`) REFERENCES `cart_rules` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cart_shipping_rates`
--
ALTER TABLE `cart_shipping_rates`
  ADD CONSTRAINT `cart_shipping_rates_cart_address_id_foreign` FOREIGN KEY (`cart_address_id`) REFERENCES `addresses` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `catalog_rule_channels`
--
ALTER TABLE `catalog_rule_channels`
  ADD CONSTRAINT `catalog_rule_channels_catalog_rule_id_foreign` FOREIGN KEY (`catalog_rule_id`) REFERENCES `catalog_rules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `catalog_rule_channels_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `catalog_rule_customer_groups`
--
ALTER TABLE `catalog_rule_customer_groups`
  ADD CONSTRAINT `catalog_rule_customer_groups_catalog_rule_id_foreign` FOREIGN KEY (`catalog_rule_id`) REFERENCES `catalog_rules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `catalog_rule_customer_groups_customer_group_id_foreign` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_groups` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `catalog_rule_products`
--
ALTER TABLE `catalog_rule_products`
  ADD CONSTRAINT `catalog_rule_products_catalog_rule_id_foreign` FOREIGN KEY (`catalog_rule_id`) REFERENCES `catalog_rules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `catalog_rule_products_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `catalog_rule_products_customer_group_id_foreign` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `catalog_rule_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `catalog_rule_product_prices`
--
ALTER TABLE `catalog_rule_product_prices`
  ADD CONSTRAINT `catalog_rule_product_prices_catalog_rule_id_foreign` FOREIGN KEY (`catalog_rule_id`) REFERENCES `catalog_rules` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `catalog_rule_product_prices_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `catalog_rule_product_prices_customer_group_id_foreign` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `catalog_rule_product_prices_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `category_filterable_attributes`
--
ALTER TABLE `category_filterable_attributes`
  ADD CONSTRAINT `category_filterable_attributes_attribute_id_foreign` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `category_filterable_attributes_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `category_translations`
--
ALTER TABLE `category_translations`
  ADD CONSTRAINT `category_translations_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `category_translations_locale_id_foreign` FOREIGN KEY (`locale_id`) REFERENCES `locales` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `channels`
--
ALTER TABLE `channels`
  ADD CONSTRAINT `channels_base_currency_id_foreign` FOREIGN KEY (`base_currency_id`) REFERENCES `currencies` (`id`),
  ADD CONSTRAINT `channels_default_locale_id_foreign` FOREIGN KEY (`default_locale_id`) REFERENCES `locales` (`id`),
  ADD CONSTRAINT `channels_root_category_id_foreign` FOREIGN KEY (`root_category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `channel_currencies`
--
ALTER TABLE `channel_currencies`
  ADD CONSTRAINT `channel_currencies_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `channel_currencies_currency_id_foreign` FOREIGN KEY (`currency_id`) REFERENCES `currencies` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `channel_inventory_sources`
--
ALTER TABLE `channel_inventory_sources`
  ADD CONSTRAINT `channel_inventory_sources_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `channel_inventory_sources_inventory_source_id_foreign` FOREIGN KEY (`inventory_source_id`) REFERENCES `inventory_sources` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `channel_locales`
--
ALTER TABLE `channel_locales`
  ADD CONSTRAINT `channel_locales_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `channel_locales_locale_id_foreign` FOREIGN KEY (`locale_id`) REFERENCES `locales` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cms_page_channels`
--
ALTER TABLE `cms_page_channels`
  ADD CONSTRAINT `cms_page_channels_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cms_page_channels_cms_page_id_foreign` FOREIGN KEY (`cms_page_id`) REFERENCES `cms_pages` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `cms_page_translations`
--
ALTER TABLE `cms_page_translations`
  ADD CONSTRAINT `cms_page_translations_cms_page_id_foreign` FOREIGN KEY (`cms_page_id`) REFERENCES `cms_pages` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `country_states`
--
ALTER TABLE `country_states`
  ADD CONSTRAINT `country_states_country_id_foreign` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `country_state_translations`
--
ALTER TABLE `country_state_translations`
  ADD CONSTRAINT `country_state_translations_country_state_id_foreign` FOREIGN KEY (`country_state_id`) REFERENCES `country_states` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `country_translations`
--
ALTER TABLE `country_translations`
  ADD CONSTRAINT `country_translations_country_id_foreign` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `currency_exchange_rates`
--
ALTER TABLE `currency_exchange_rates`
  ADD CONSTRAINT `currency_exchange_rates_target_currency_foreign` FOREIGN KEY (`target_currency`) REFERENCES `currencies` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_customer_group_id_foreign` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_groups` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `downloadable_link_purchased`
--
ALTER TABLE `downloadable_link_purchased`
  ADD CONSTRAINT `downloadable_link_purchased_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `downloadable_link_purchased_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `downloadable_link_purchased_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `invoices_order_address_id_foreign` FOREIGN KEY (`order_address_id`) REFERENCES `addresses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `invoices_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD CONSTRAINT `invoice_items_invoice_id_foreign` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `invoice_items_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `invoice_items` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `marketplace_bulkupload_admin_dataflowprofile`
--
ALTER TABLE `marketplace_bulkupload_admin_dataflowprofile`
  ADD CONSTRAINT `mp_bulkupload_admin_foreign_attribute_family_id` FOREIGN KEY (`attribute_family_id`) REFERENCES `attribute_families` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `marketplace_bulkupload_dataflowprofile`
--
ALTER TABLE `marketplace_bulkupload_dataflowprofile`
  ADD CONSTRAINT `mp_bulkupload_foreign_attribute_family_id` FOREIGN KEY (`attribute_family_id`) REFERENCES `attribute_families` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `marketplace_import_new_products`
--
ALTER TABLE `marketplace_import_new_products`
  ADD CONSTRAINT `marketplace_import_new_products_data_flow_profile_id_foreign` FOREIGN KEY (`data_flow_profile_id`) REFERENCES `marketplace_bulkupload_dataflowprofile` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `mp_import_foreign_attribute_family_id` FOREIGN KEY (`attribute_family_id`) REFERENCES `attribute_families` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `marketplace_import_new_products_by_admin`
--
ALTER TABLE `marketplace_import_new_products_by_admin`
  ADD CONSTRAINT `mp_import_admin_foreign_attribute_family_id` FOREIGN KEY (`attribute_family_id`) REFERENCES `attribute_families` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `mp_import_admin_foreign_data_flow_profile_id` FOREIGN KEY (`data_flow_profile_id`) REFERENCES `marketplace_bulkupload_dataflowprofile` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orders_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `order_brands`
--
ALTER TABLE `order_brands`
  ADD CONSTRAINT `order_brands_brand_foreign` FOREIGN KEY (`brand`) REFERENCES `attribute_options` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_brands_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_brands_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_brands_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `order_payment`
--
ALTER TABLE `order_payment`
  ADD CONSTRAINT `order_payment_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_attribute_family_id_foreign` FOREIGN KEY (`attribute_family_id`) REFERENCES `attribute_families` (`id`),
  ADD CONSTRAINT `products_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_attribute_values`
--
ALTER TABLE `product_attribute_values`
  ADD CONSTRAINT `product_attribute_values_attribute_id_foreign` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_attribute_values_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_bundle_options`
--
ALTER TABLE `product_bundle_options`
  ADD CONSTRAINT `product_bundle_options_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_bundle_option_products`
--
ALTER TABLE `product_bundle_option_products`
  ADD CONSTRAINT `product_bundle_option_products_product_bundle_option_id_foreign` FOREIGN KEY (`product_bundle_option_id`) REFERENCES `product_bundle_options` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_bundle_option_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_bundle_option_translations`
--
ALTER TABLE `product_bundle_option_translations`
  ADD CONSTRAINT `product_bundle_option_translations_option_id_foreign` FOREIGN KEY (`product_bundle_option_id`) REFERENCES `product_bundle_options` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_categories`
--
ALTER TABLE `product_categories`
  ADD CONSTRAINT `product_categories_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_categories_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_cross_sells`
--
ALTER TABLE `product_cross_sells`
  ADD CONSTRAINT `product_cross_sells_child_id_foreign` FOREIGN KEY (`child_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_cross_sells_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_downloadable_links`
--
ALTER TABLE `product_downloadable_links`
  ADD CONSTRAINT `product_downloadable_links_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_downloadable_link_translations`
--
ALTER TABLE `product_downloadable_link_translations`
  ADD CONSTRAINT `link_translations_link_id_foreign` FOREIGN KEY (`product_downloadable_link_id`) REFERENCES `product_downloadable_links` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_downloadable_samples`
--
ALTER TABLE `product_downloadable_samples`
  ADD CONSTRAINT `product_downloadable_samples_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_downloadable_sample_translations`
--
ALTER TABLE `product_downloadable_sample_translations`
  ADD CONSTRAINT `sample_translations_sample_id_foreign` FOREIGN KEY (`product_downloadable_sample_id`) REFERENCES `product_downloadable_samples` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_flat`
--
ALTER TABLE `product_flat`
  ADD CONSTRAINT `product_flat_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `product_flat` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_flat_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_grouped_products`
--
ALTER TABLE `product_grouped_products`
  ADD CONSTRAINT `product_grouped_products_associated_product_id_foreign` FOREIGN KEY (`associated_product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_grouped_products_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `product_images_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_inventories`
--
ALTER TABLE `product_inventories`
  ADD CONSTRAINT `product_inventories_inventory_source_id_foreign` FOREIGN KEY (`inventory_source_id`) REFERENCES `inventory_sources` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_inventories_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_ordered_inventories`
--
ALTER TABLE `product_ordered_inventories`
  ADD CONSTRAINT `product_ordered_inventories_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_ordered_inventories_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_relations`
--
ALTER TABLE `product_relations`
  ADD CONSTRAINT `product_relations_child_id_foreign` FOREIGN KEY (`child_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_relations_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD CONSTRAINT `product_reviews_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_super_attributes`
--
ALTER TABLE `product_super_attributes`
  ADD CONSTRAINT `product_super_attributes_attribute_id_foreign` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`id`),
  ADD CONSTRAINT `product_super_attributes_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `product_up_sells`
--
ALTER TABLE `product_up_sells`
  ADD CONSTRAINT `product_up_sells_child_id_foreign` FOREIGN KEY (`child_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `product_up_sells_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `refunds`
--
ALTER TABLE `refunds`
  ADD CONSTRAINT `refunds_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `refund_items`
--
ALTER TABLE `refund_items`
  ADD CONSTRAINT `refund_items_order_item_id_foreign` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `refund_items_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `refund_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `refund_items_refund_id_foreign` FOREIGN KEY (`refund_id`) REFERENCES `refunds` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `shipments`
--
ALTER TABLE `shipments`
  ADD CONSTRAINT `shipments_inventory_source_id_foreign` FOREIGN KEY (`inventory_source_id`) REFERENCES `inventory_sources` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `shipments_order_address_id_foreign` FOREIGN KEY (`order_address_id`) REFERENCES `addresses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `shipments_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `shipment_items`
--
ALTER TABLE `shipment_items`
  ADD CONSTRAINT `shipment_items_shipment_id_foreign` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `sliders`
--
ALTER TABLE `sliders`
  ADD CONSTRAINT `sliders_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `subscribers_list`
--
ALTER TABLE `subscribers_list`
  ADD CONSTRAINT `subscribers_list_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `tax_categories_tax_rates`
--
ALTER TABLE `tax_categories_tax_rates`
  ADD CONSTRAINT `tax_categories_tax_rates_tax_category_id_foreign` FOREIGN KEY (`tax_category_id`) REFERENCES `tax_categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tax_categories_tax_rates_tax_rate_id_foreign` FOREIGN KEY (`tax_rate_id`) REFERENCES `tax_rates` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `velocity_contents_translations`
--
ALTER TABLE `velocity_contents_translations`
  ADD CONSTRAINT `velocity_contents_translations_content_id_foreign` FOREIGN KEY (`content_id`) REFERENCES `velocity_contents` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `velocity_customer_compare_products`
--
ALTER TABLE `velocity_customer_compare_products`
  ADD CONSTRAINT `velocity_customer_compare_products_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `velocity_customer_compare_products_product_flat_id_foreign` FOREIGN KEY (`product_flat_id`) REFERENCES `product_flat` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `wishlist`
--
ALTER TABLE `wishlist`
  ADD CONSTRAINT `wishlist_channel_id_foreign` FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlist_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlist_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
