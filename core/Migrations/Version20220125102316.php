<?php
namespace OC\Migrations;

use Doctrine\DBAL\Schema\Schema;
use OCP\Migration\ISchemaMigration;

/**
 * Auto-generated migration step: Please modify to your needs!
 */
class Version20220125102316 implements ISchemaMigration {

	public function changeSchema(Schema $schema, array $options) {
		$prefix = $options['tablePrefix'];
		if ($schema->hasTable("${prefix}share")) {
			$shareTable = $schema->getTable("${prefix}share");

			if (!$shareTable->hasColumn('show_options')) {
				$shareTable->addColumn(
					'show_options',
					'integer',
					[
						'default' => 0,
						'notnull' => false
					]
				);
			}
                        if (!$shareTable->hasColumn('description')) {
                                $shareTable->addColumn(
                                        'description',
                                        'string',
                                        [
                                                'default' => null,
						'length' => 1024,
						'notnull' => false
                                        ]
                                );
                        }
		}			
	}
}
