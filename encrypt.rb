require 'aws-sdk'

# AWS access_key_id, secret_key_id
credentials = Aws::Credentials.new('AKIAIWEEFR2JUOKQW7WQ', '0F7WYVaQiiIDxSf2H3N24XTh9gnxobXEwGRszLRB', nil)

###############################
# encrypting the file with KMS
###############################

# creating a new KMS Client object
kms_client = Aws::KMS::Client.new(
  region: 'us-east-1',
  credentials: credentials
)

# file to be encrypted
ifile = ARGV[0]
in_file = IO.binread(ifile)

# output file
ofile = ARGV[1]
out_file = File.new(ofile, 'w')

# KMS master key
key_id = 'arn:aws:kms:us-east-1:369630458899:key/f01a8069-9c21-49e2-a1b7-43bc7cc0c382'

# encrypting the text
enc = kms_client.encrypt({
  key_id: key_id,
  plaintext: in_file
  })

#######################################
# uploading the encrypted file to S3
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
