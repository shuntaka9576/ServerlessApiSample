from libs.api_controller import Controller, validate
from libs.aws_resource_controller import dynamoController

schema = {"id": {"type": "string", "regex": "[0-9].*"}}


class GetIdController(Controller):
    @validate(schema)
    def handler(self, params):
        """
        GET /coupons/{id} 問い合わせ処理
        Lambdaから渡されたパラメータを受け取り、応答を返す
            :param self: インスタンス
            :param params: 辞書型
        """
        reqid = params["id"]
        res = dynamoController().searchId(reqid)

        if res["Count"] == 0:
            return self.bad(
                {
                    "header": {
                        "status": "Error",
                        "errors": [{"field": "id", "message": "Unsupported coupon id"}],
                    }
                }
            )

        return self.ok(
            {
                "header": {"status": "Success", "errors": []},
                "response": {"coupons": [res["Items"][0]]},
            }
        )
