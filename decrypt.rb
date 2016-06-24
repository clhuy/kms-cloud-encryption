require 'aws-sdk'
require 'byebug'

# AWS access_key_id, secret_key_id
credentials = Aws::Credentials.new('AKIAIWEEFR2JUOKQW7WQ', '0F7WYVaQiiIDxSf2H3N24XTh9gnxobXEwGRszLRB', nil)

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
ofile = ARGV[0]
out_file = File.new(ofile, 'w')

# write out the decrypted plaintext
out_file.write(dec.plaintext)
#out_file.close
