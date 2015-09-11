# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/filters/grok"
require 'tempfile'

describe LogStash::Filters::Grok do

  config <<-CONFIG
    filter {
      #{File.read("target/logstash-filters-default.conf")}
    }
  CONFIG

  describe "Parse BOSH nats messages" do

    describe "hm_agent_heartbeat" do

      sample("@type" => "NATS", 
		"subject" => "hm.agent.heartbeat.e994bb46-f8ac-4f65-b639-ac1f1e546c32", "reply" => nil, 
		"@message" => '{"job":"router-partition-7c53ed3ae2e7f5543b91","index":0,"job_state":"running","vitals":{"cpu":{"sys":"0.0","user":"0.1","wait":"0.1"},"disk":{"ephemeral":{"inode_percent":"2","percent":"5"},"system":{"inode_percent":"37","percent":"46"}},"load":["0.00","0.02","0.05"],"mem":{"kb":"81812","percent":"8"},"swap":{"kb":"0","percent":"0"}}}') do

        #puts subject.to_hash.to_yaml
        #puts subject['vitals'].inspect.to_yaml

        insist { subject["tags"] } == ["hm_agent_heartbeat"]
        insist { subject["@type"] } == "NATS"
       
        insist { subject["job_and_index"] } == "router-partition-7c53ed3ae2e7f5543b91/0"
        insist { subject["job"] } == "router-partition-7c53ed3ae2e7f5543b91" 
        insist { subject["index"] } == 0 
        insist { subject["job_state"] } == "running"

        insist { subject["vitals"] } == {
					"cpu" => {
						     "sys" => 0.0,
						    "user" => 0.1,
						    "wait" => 0.1
					},
					"disk" => {
					    "ephemeral" => {
							"inode_percent" => 2.0,
							      "percent" => 5.0
						},
					    "system" => {
							"inode_percent" => 37.0,
							"percent" => 46.0
					    }
					},
					"load" => {
					    "avg01" => 0.0,
					    "avg05" => 0.02,
					    "avg15" => 0.05
					},
					"mem" => {
						 "kb" => 81812.0,
					    "percent" => 8.0
					},
					"swap" => {
						 "kb" => 0.0,
					    "percent" => 0.0
					}
				    }

      end

    end # describe "hm_agent_heartbeat"
  
  end # describe "Parse BOSH nats messages"

end # describe LogStash::Filters::Grok do

