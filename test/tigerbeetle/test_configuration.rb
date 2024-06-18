require 'minitest/autorun'
require 'fileutils'
require 'open3'
require_relative '../../lib/tigerbeetle/ruby/types/uint'
require_relative '../../lib/tigerbeetle/ruby/client'

class IntegrationTest < Minitest::Test
  DB_DIR = 'tmp/db'
  TIGERBEETLE_CMD = 'tigerbeetle'

  def setup
    @port = 3033
    @cluster_id = UInt128.new(0)
    @replica_id = 0
    @replica_count = 1
    @concurrency_max = 8192

    FileUtils.mkdir_p(DB_DIR)
    @db_file = format_db

    @tb_process = start_tigerbeetle
    @tb_client = Client.new(@cluster_id, [@port.to_s], @concurrency_max)
  end

  def teardown
    stop_tigerbeetle(@tb_process)
    @tb_client.close
    FileUtils.rm_rf(DB_DIR)
  end

  private

  def format_db
    file_name = "#{@cluster_id}_#{@replica_id}.tigerbeetle"
    file_path = File.join(DB_DIR, file_name)
    cluster_id_arg = "--cluster=#{@cluster_id}"
    replica_arg = "--replica=#{@replica_id}"
    replica_count_arg = "--replica-count=#{@replica_count}"

    cmd = [
      TIGERBEETLE_CMD,
      'format',
      cluster_id_arg,
      replica_arg,
      replica_count_arg,
      file_path
    ]

    system(*cmd, out: File::NULL) or raise 'TigerBeetle format failed'

    file_path
  end

  def start_tigerbeetle
    address_arg = "--address=#{@port}"
    cache_size_arg = '--cache-grid=256MiB'
    cmd = [
      TIGERBEETLE_CMD,
      'start',
      address_arg,
      cache_size_arg,
      @db_file
    ]

    IO.popen(cmd, 'r+')
  end

  def stop_tigerbeetle(process)
    Process.kill('TERM', process.pid)
    process.close
  end

  # Example test
  def test_client_connection
    assert @tb_client.connected?, "Client should be connected"
  end
end