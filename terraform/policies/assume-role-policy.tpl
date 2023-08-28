{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_root_user}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}