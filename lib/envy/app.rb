module Envy
  class App
    
    extend GLI::App

    program_desc 'Describe your application here'

    version Envy::VERSION

    subcommand_option_handling :normal
    arguments :strict

    desc 'Describe some switch here'
    switch [:s,:switch]

    desc 'Describe some flag here'
    default_value 'the default'
    arg_name 'The name of the argument'
    flag [:f,:flagname]

    desc 'Describe write here'
    arg_name 'Describe arguments to write here'
    arg :infile=> :required, :outfile=> :required
    command :write do |c|
      c.desc 'Describe a switch to write'
      c.switch :s

      c.desc 'Describe a flag to write'
      c.default_value 'default'
      c.flag :f
      c.action do |global_options,options,args|

        # Your command logic here

        # If you have any errors, just raise them
        # raise "that command made no sense"

        # AWS access_key_id, secret_key_id
        credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'], nil)

        ######################
        # encrypting the file
        ######################

        # file to be encrypted
        in_file = IO.binread(args[0])

        # output file
        out_file = File.new(args[1], 'w+')

        # creating a new KMS Client object
        kms_client = Aws::KMS::Client.new(
          region: 'us-east-1',
          credentials: credentials
        )

        # encrypting the text
        enc = kms_client.encrypt({
          key_id: ENV['key_id'],
          plaintext: in_file
          })

        #######################################
        # uploading the encrypted file from S3
        #######################################

        # write out the encrypted plaintext
        out_file.write(enc.ciphertext_blob)
        out_file.close

        # creating a new S3 Client object
        s3_client = Aws::S3::Client.new(
          credentials: credentials,
          region: 'us-west-2'
        )

        # putting the encrypted file into S3
        s3_client.put_object({
          body: out_file,
          bucket: 'd-vault',
          key: 'encrypted_file'
          })

        puts "write command ran"
      end
    end

    desc 'Describe read here'
    arg_name 'Describe arguments to read here'
    arg :outfile => :required
    command :read do |c|
      c.action do |global_options,options,args|

        # AWS access_key_id, secret_key_id
        credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'], nil)

        #######################################
        # retreiving the encrypted file from S3
        #######################################

        # creating a new S3 Client object
        s3_client = Aws::S3::Client.new(
          credentials: credentials,
          region: 'us-west-2'
        )

        # retrieving the file
        response = s3_client.get_object({
          bucket: 'd-vault',
          key: 'encrypted_file'
          })

        ######################
        # decrypting the file
        ######################

        # creating a new KMS Client object
        kms_client = Aws::KMS::Client.new(
          region: 'us-east-1',
          credentials: credentials
        )

        # decrypting the text
        dec = kms_client.decrypt({
          ciphertext_blob: response.body.string
        })

        # creating an output File object
        out_file = File.new(args[0], 'w')

        # write out the decrypted plaintext
        out_file.write(dec.plaintext)
        out_file.close

        puts "read command ran"
      end
    end

    pre do |global,command,options,args|
      # Pre logic here
      # Return true to proceed; false to abort and not call the
      # chosen command
      # Use skips_pre before a command to skip this block
      # on that command only
      true
    end

    post do |global,command,options,args|
      # Post logic here
      # Use skips_post before a command to skip this
      # block on that command only
    end

    on_error do |exception|
      # Error logic here
      # return false to skip default error handling
      true
    end

  end
end
