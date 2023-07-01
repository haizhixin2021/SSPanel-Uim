<?php

declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Controllers\BaseController;
use App\Models\UserTrafficLog;
use App\Utils\Tools;
use Exception;
use Psr\Http\Message\ResponseInterface;
use Slim\Http\Response;
use Slim\Http\ServerRequest;

final class UserTrafficLogController extends BaseController
{
    public static array $details =
    [
        'field' => [
            'id' => '记录ID',
            'user_id' => '用户ID',
            'u' => '上传流量',
            'd' => '下载流量',
            'node_id' => '节点ID',
            'node_name' => '节点名称',
            'rate' => '倍率',
            'traffic' => '结算流量',
            'log_time' => '时间',
        ],
    ];

    /**
     * 后台流量记录页面
     *
     * @throws Exception
     */
    public function index(ServerRequest $request, Response $response, array $args): ResponseInterface
    {
        return $response->write(
            $this->view()
                ->assign('details', self::$details)
                ->fetch('admin/log/usertrafficlog.tpl')
        );
    }

    /**
     * 后台流量记录页面 AJAX
     */
    public function ajax(ServerRequest $request, Response $response, array $args): ResponseInterface
    {
        $length = $request->getParam('length');
        $page = $request->getParam('start') / $length + 1;
        $draw = $request->getParam('draw');

        $usertrafficlogs = UserTrafficLog::orderBy('id', 'desc')->paginate($length, '*', '', $page);
        $total = UserTrafficLog::count();

        foreach ($usertrafficlogs as $trafficlog) {
            //$trafficlog->traffic = round(Tools::flowToGB($trafficlog->traffic), 2);
            //$trafficlog->hourly_usage = round(Tools::flowToGB($trafficlog->hourly_usage), 2);
            $trafficlog->u = Tools::flowAutoShow($trafficlog->u); 
            $trafficlog->d = Tools::flowAutoShow($trafficlog->d);
            $trafficlog->traffic = $trafficlog->traffic;
            $trafficlog->log_time = Tools::toDateTime((int) $trafficlog->log_time);
        }

        return $response->withJson([
            'draw' => $draw,
            'recordsTotal' => $total,
            'recordsFiltered' => $total,
            'usertrafficlogs' => $usertrafficlogs,
        ]);
    }
}
