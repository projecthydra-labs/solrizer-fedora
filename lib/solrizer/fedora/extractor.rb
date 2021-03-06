require 'rexml/document'
require "nokogiri"
require 'yaml'

# Solrizer::Fedora::Extractor provides Fedora-specific extractor behaviors
# This module is automatically mixed into Solrizer::Extractor when you load the solrizer-fedora gem into an application.  This is carried out in solrizer/fedora.rb 
module Solrizer::Fedora::Extractor

  #
  # Extracts content-model and hydra-type from RELS-EXT datastream
  #
  def extract_rels_ext( text, solr_doc=Hash.new )
    # TODO: only read in this file once
    
    if defined?(Rails.root.to_s)
      config_path = File.join(Rails.root.to_s, "config","hydra_types.yml")
      config_path = nil unless File.exist?(config_path)
    end
    unless config_path
      config_path = File.join(File.dirname(__FILE__), "..", "..", "..", "config","hydra_types.yml")
    end
    
    
    map = YAML.load(File.open(config_path))
    
    doc = Nokogiri::XML(text)
    doc.xpath( '//foo:hasModel', 'foo' => 'info:fedora/fedora-system:def/model#' ).each do |element|
      cmodel = element.attributes['resource'].to_s
      ::Solrizer::Extractor.insert_solr_field_value(solr_doc,  :cmodel_t, cmodel )
      
      if map.has_key?(cmodel)
        ::Solrizer::Extractor.insert_solr_field_value(solr_doc, :hydra_type_t, map[cmodel] )
      end
    end

    return solr_doc
  end
  
end
