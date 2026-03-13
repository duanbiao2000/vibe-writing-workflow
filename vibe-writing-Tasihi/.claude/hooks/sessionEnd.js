/**
 * SessionEnd Hook: 对话论述自动保存兜底机制
 *
 * 功能：在每次对话结束时检查对话论述同步状态
 * - 对比项目信息中的"最新同步轮次"与对话论述.md中的实际轮次
 * - 如果发现不一致，记录警告并提示用户
 *
 * 版本：v1.0
 * 创建：2026-03-13
 */

const fs = require('fs');
const path = require('path');

/**
 * 从项目信息文件中提取对话论述同步状态
 * @param {string} projectInfoPath - 项目信息文件路径
 * @returns {Object} { lastSyncedRound: number, status: string, date: string }
 */
function extractSyncStatus(projectInfoPath) {
    try {
        const content = fs.readFileSync(projectInfoPath, 'utf-8');

        // 提取"最新同步轮次"
        const roundMatch = content.match(/\*\*最新同步轮次\*\*：第(\d+)轮/);
        // 提取"状态"
        const statusMatch = content.match(/\*\*状态\*\*：(\S+)/);

        return {
            lastSyncedRound: roundMatch ? parseInt(roundMatch[1]) : 0,
            status: statusMatch ? statusMatch[1] : '未知'
        };
    } catch (error) {
        return { lastSyncedRound: 0, status: '文件读取失败' };
    }
}

/**
 * 从对话论述文件中提取最新轮次
 * @param {string} discoursePath - 对话论述文件路径
 * @returns {number} 最新轮次编号
 */
function extractLatestDiscourseRound(discoursePath) {
    try {
        const content = fs.readFileSync(discoursePath, 'utf-8');

        // 查找所有"## 第X轮对话"的匹配
        const matches = content.match(/## 第(\d+)轮对话/g);

        if (!matches || matches.length === 0) {
            return 0;
        }

        // 提取最后一个匹配的轮次号
        const lastMatch = matches[matches.length - 1];
        const roundMatch = lastMatch.match(/第(\d+)轮/);

        return roundMatch ? parseInt(roundMatch[1]) : 0;
    } catch (error) {
        return 0;
    }
}

/**
 * 查找当前工作目录下的项目信息文件
 * @param {string} cwd - 当前工作目录
 * @returns {string|null} 项目信息文件路径
 */
function findProjectInfo(cwd) {
    // 尝试在 项目/*/项目信息.md
    const projectDirs = fs.readdirSync(path.join(cwd, '项目'), { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name);

    for (const projectName of projectDirs) {
        const infoPath = path.join(cwd, '项目', projectName, '项目信息.md');
        if (fs.existsSync(infoPath)) {
            return infoPath;
        }
    }

    return null;
}

/**
 * Hook主函数
 * @param {Object} context - Hook上下文
 */
module.exports = async (context) => {
    const { cwd } = context;

    // 1. 查找项目信息文件
    const projectInfoPath = findProjectInfo(cwd);
    if (!projectInfoPath) {
        return; // 没有项目信息，跳过检查
    }

    // 2. 提取同步状态
    const syncStatus = extractSyncStatus(projectInfoPath);

    // 3. 查找并检查对话论述文件
    const projectDir = path.dirname(projectInfoPath);
    const discoursePath = path.join(projectDir, '对话论述.md');

    if (!fs.existsSync(discoursePath)) {
        // 对话论述文件不存在，但项目信息显示应该有同步记录
        if (syncStatus.lastSyncedRound > 0) {
            console.warn(`⚠️ 警告：对话论述文件不存在，但项目信息显示最新同步轮次为第${syncStatus.lastSyncedRound}轮`);
            console.warn(`   建议检查：${discoursePath}`);
        }
        return;
    }

    // 4. 提取实际轮次
    const actualRound = extractLatestDiscourseRound(discoursePath);

    // 5. 对比轮次
    if (actualRound < syncStatus.lastSyncedRound) {
        console.warn(`⚠️ 对话论述可能存在遗漏`);
        console.warn(`   项目信息显示：第${syncStatus.lastSyncedRound}轮已同步`);
        console.warn(`   对话论述实际：第${actualRound}轮`);
        console.warn(`   差异：${syncStatus.lastSyncedRound - actualRound}轮内容可能未保存`);
        console.warn(`   对话论述路径：${discoursePath}`);
    } else if (actualRound > syncStatus.lastSyncedRound) {
        console.warn(`⚠️ 项目信息的同步状态可能过时`);
        console.warn(`   对话论述实际：第${actualRound}轮`);
        console.warn(`   项目信息记录：第${syncStatus.lastSyncedRound}轮`);
        console.warn(`   建议：更新项目信息中的"对话论述同步"字段`);
    }

    // 6. 检查同步状态标记
    if (syncStatus.status.includes('待同步')) {
        console.warn(`⚠️ 项目信息显示对话论述处于"待同步"状态`);
        console.warn(`   请检查是否有对话论述未保存`);
    }
};
