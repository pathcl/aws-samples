package main

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
)

func main() {
	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithClientLogMode(aws.LogRequestWithBody|aws.LogResponseWithBody))
	if err != nil {
		panic("configuration error, " + err.Error())
	}

	client := ec2.NewFromConfig(cfg)
	result, err := client.DescribeInstances(context.Background(), &ec2.DescribeInstancesInput{})
	if err != nil {
		panic("error listing instances, " + err.Error())
	}

	for _, reservation := range result.Reservations {
		for _, instance := range reservation.Instances {
			println("Instance ID: " + *instance.InstanceId)
		}
	}
}
