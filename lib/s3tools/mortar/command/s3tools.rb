require "aws-sdk"
require "mortar/command/base"
require "s3tools/mortar/s3tools/lib"

# Tools for downloading data from S3
class Mortar::Command::S3Tools < Mortar::Command::Base
  # s3tools:getmerge S3_PATH LOCAL_PATH
  #
  # Retrieves and concatenates files in an S3 directory.
  #
  # Examples:
  #
  #    $ mortar s3tools:getmerge s3://my-bucket/my-output/ ~/data/my_output.txt
  def getmerge
    s3_path    = shift_argument
    local_path = shift_argument 
    unless s3_path and local_path
      error("Usage: mortar s3tools:getmerge S3_PATH LOCAL_PATH\nMust specify S3_PATH, LOCAL_PATH.")
    end
    validate_arguments!

    s3                  = Mortar::S3Tools::Lib.getS3()
    bucket_name, prefix = s3_path.sub(/s3n?:\/\//, "").split("/", 2)
    bucket              = s3.buckets[bucket_name]
    tree                = bucket.as_tree(:prefix => prefix)
    parts               = tree.children.select {|node| node.leaf? and not File.basename(node.key)[0] == "."}.collect(&:key)

    File.open(local_path, "w") do |file|
      parts.each do |key|
        display "Downloading s3://#{bucket_name}/#{key}"
        bucket.objects[key].read do |chunk|
          file.write(chunk)
        end
      end
    end
  end

  # s3tools:fetchoutput JOB_ID LOCAL_DIR
  #
  # Retrieves and concatenates the files for each output of a job.
  #
  # Examples:
  #
  #    $ mortar s3tools:fetchoutput 51b667e0d7188272befda2bb ~/data/my_output_dir
  #
  def fetchoutput
    job_id    = shift_argument
    local_dir = shift_argument
    unless job_id and local_dir
      error("Usage: mortar s3tools:fetchoutput JOB_ID LOCAL_DIR\nMust specify JOB_ID, LOCAL_DIR.")
    end
    validate_arguments!

    job = api.get_job(job_id).body
    if not job["outputs"]
      error("No outputs found for job #{job_id}")
    end

    if job["script_type"] == "cli_control"
      error("fetchoutput does not support controlscripts")
    end

    job["outputs"].each do |output|
      if output["output_blobs"].size == 0
        warning("Output #{output["alias"]} is empty")
      else
        Mortar::Command::run("s3tools:getmerge", [output["location"], "#{local_dir}/#{output["alias"]}"])
      end
    end
  end
end

