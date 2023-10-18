from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from typing import Sequence

#You can inherit from other operator of course
class RGCustomOperator(BaseOperator):
    
    template_fields: Sequence[str] = ("connection", "param")
    
    #Apply apply_defaults decorator
    @apply_defaults
    def __init__(self,
                 connection = "connection if needed",
                 param = "parameter if needed",
                 *args, **kwargs):

        super(RGCustomOperator, self).__init__(*args, **kwargs)
        #Store attributes in class
        self.connection = connection
        self.param = param
        
    def execute(self, context):
        """
        Execution function of RGCustomOperator
        """
        #Write logs if needed
        self.log.info(f"Simulate some connection to a random off-cloud Mongo Cluster; using connection {self.connection} and a random param of {self.param}")
