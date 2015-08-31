gem "minitest"
require 'minitest/autorun'
require 'wbspider'

class AgentTest < Minitest::Test
  @@config_test = {
    :username => 'jiyaping0802@gmail.com',
    :password => 'xxxxxxxxxxxxxx'
  }
=begin
  @@agent = Wbspider::Agent.new(Wbspider.config.merge @@config_test)

  def test_initalize
    assert @@agent
  end

  def test_initalize_userid
    assert @@agent.init_userid
  end

  def test_timeline_model
    assert @@agent.timeline.models.first
  end

  def test_index
    assert @@agent.index.models.first
  end

  def test_fans
    assert @@agent.fans.models.first
  end

  def test_follow
    assert @@agent.follow.models.first
  end
=end
end